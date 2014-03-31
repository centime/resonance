/*
* The contents of this file are subject to the Mozilla Public
* License Version 1.1 (the "License"); you may not use this file
* except in compliance with the License. You may obtain a copy of
* the License at http://www.mozilla.org/MPL/
*
* Software distributed under the License is distributed on an "AS
* IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
* implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is JSIRC Library
 *
 * The Initial Developer of the Original Code is New Dimensions Consulting, Inc.
 *
 * Portions created by the Initial Developer are Copyright (C) 1999
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *   Robert Ginda, <rginda@ndcico.com>, original author
 *   Peter Van der Beken, <peter.vanderbeken@pandora.be>, necko-only version
 *   Stephen Clavering <mozilla@clav.me.uk>, extensively rewritten for
 *     MSNMessenger (http://msnmsgr.mozdev.org/)
 *   Patrick Cloke, <clokep@gmail.com>, updated, extended and generalized for
 *     Instantbird (http://www.instantbird.com)
 */
 /*
 * Combines a lot of the Mozilla networking interfaces into a sane interface for
 * simple(r) use of sockets code.
 *
 * This implements nsIServerSocketListener, nsIStreamListener,
 * nsIRequestObserver, and nsITransportEventSink.
 * This uses nsISocketTransportServices, nsIServerSocket, nsIThreadManager,
 * nsIBinaryInputStream, nsIScriptableInputStream, nsIInputStreamPump
 *
 * High-level methods:
 *   .connect(host, port[, ("ssl" | "tls") [, proxy[, mode]]])
 *   .disconnect()
 *   .listen(port)
 *   .send(data, timeout)
 * High-level properties:
 *   .isConnected
 *
 * Users should "subclass" this object, i.e. set their .__proto__ to be it. And
 * then implement:
 *   onConnectionHeard()
 *   onConnectionTimedOut()
 *   onConnectionReset()
 *   onDataReceived(data)
 *   onBinaryDataReceived(data, length)
 */
 var EXPORTED_SYMBOLS = ["mozSocket"];
const {Cc, Ci, Cu} = require('chrome');//Components;
//Cu.import("resource:///modules/imServices.jsm");
// Network errors see: netwerk/base/public/nsNetError.h
const NS_ERROR_MODULE_NETWORK = 2152398848;
const NS_ERROR_CONNECTION_REFUSED = NS_ERROR_MODULE_NETWORK + 13;
const NS_ERROR_NET_TIMEOUT = NS_ERROR_MODULE_NETWORK + 14;
const NS_ERROR_NET_RESET = NS_ERROR_MODULE_NETWORK + 20;
const NS_ERROR_UNKNOWN_HOST = NS_ERROR_MODULE_NETWORK + 30;
const NS_ERROR_UNKNOWN_PROXY_HOST = NS_ERROR_MODULE_NETWORK + 42;
const NS_ERROR_PROXY_CONNECTION_REFUSED = NS_ERROR_MODULE_NETWORK + 72;
mozSocket = {
  binaryMode: false,
  security: [],
  proxy: null,
  isConnected: false,
  _dataBuffer: "", // incoming data buffer.  character encoding is unknown
  _timeout: null, // return value of setTimeout
  /*
   *****************************************************************************
   ******************************* Public methods ******************************
   *****************************************************************************
   */
  // Synchronously open a connection.
          connect: function(aHost, aPort, aIsSSL, aProxy, aBinaryMode, aDelimOrSegSize) {
              this._log("<o> Connecting to: " + aHost + ":" + aPort);
              this.host = aHost;
              this.port = aPort;
              this.security = [];
              if (!!aIsSSL)
                security.push("ssl")
              /*if (!!aIsTLS)
                  security.push("tls");*/
              if (aProxy)
                this.proxy = aProxy;
              this.binaryMode = !!aBinaryMode;
              if (this.binaryMode)
                this._segmentSize = aDelimOrSegSize;
              else
                this._delimiter = aDelimOrSegSize;

              this.isConnected = true;
              this._dataBuffer = "";
          
              let socketTS = Cc["@mozilla.org/network/socket-transport-service;1"]
                                .getService(Ci.nsISocketTransportService);
              this.transport = socketTS.createTransport(this.security,
                                                        this.security.length, this.host,
                                                        this.port, this.proxy);
          
              this._openStreams();
              },
            
              // Disconnect all open streams.
              disconnect: function() {
                this._log(">o< Disconnect");
                if (this._inputStream)
                  this._inputStream.close();
                if (this._outputStream)
                  this._outputStream.close();
                // this._socketTransport.close(Components.results.NS_OK);
                this.isConnected = false;
              },
            
              // Listen for a connection on a port.
              // XXX take a timeout and then call stop listening/
              listen: function(port) {
                this._log("<o> Listening on port " + port);
            
                this.serverSocket = Cc["@mozilla.org/network/server-socket;1"]
                                       .createInstance(Ci.nsIServerSocket);
                this.serverSocket.init(port, false, -1);
                this.serverSocket.asyncListen(this);
              },
            
              // Stop listening for a connection.
              stopListening: function() {
                this._log(">o< Stop listening");
                if (this.serverSocket)
                  this.serverSocket.close();
              },
            
              // Send data on the output stream.
              send: function(aData, aTimeout) {
                this._log("Send data: <" + aData + ">");
                try {
                  this._outputStream.write(aData, aData.length);
                  if (aTimeout) {
                    if (this._timeout)
                      clearTimeout(this._timeout);
                    this._timeout = setTimeout(onTimeOutHelper, aTimeout, this); // i.e. onTimeOutHelper(this)
                  }
                } catch(e) {
                  this.isConnected = false;
                }
              },
            
              /*
               *****************************************************************************
               ***************************** Interface methods *****************************
               *****************************************************************************
               */
              /*
               * nsIServerSocketListener methods
               */
              // Called when a client connection is accepted.
              onSocketAccepted: function(aSocket, aTransport) {
                this._log("<o> onSocketAccepted");
                this.transport = aTransport;
                this.host = this.transport.host;
                this.port = this.transport.port;
                this._dataBuffer = "";
                this.isConnected = true;
            
                this._openStreams();
            
                this.onConnectionHeard();
                this.stopListening();
              },
              // Called when the listening socket stops for some reason.
              // The server socket is effectively dead after this notification.
              onStopListening: function(aSocket, aStatus) {
                this._log("onStopListening");
                delete this.serverSock;
              },
            
              /*
               * nsIStreamListener methods
               */
              // onDataAvailable, called by Mozilla's networking code.
              // Buffers the data, and parses it into discrete messages.
              onDataAvailable: function(aRequest, aContext, aInputStream, aOffset, aCount) {
                if (this.binaryMode)
                  this._dataBuffer += this._binaryInputStream.readBytes(aCount);
                else
                  this._dataBuffer += this._scriptableInputStream.read(aCount);
                if (this._timeout)
                  clearTimeout(this._timeout);
            
                if (this.binaryMode) {
                  // XXX this is most likely incorrect
                  this.onBinaryDataReceived(this._dataBuffer, this._dataBuffer.length);
                } else {
                  let data = this._dataBuffer.split('\n');// FIX this._delimiter);
            
                  // Store the (possibly) incomplete part
                  this._dataBuffer = data.pop();
            
                  // For each string, handle the data
                  data.forEach(this.onDataReceived)
                }
              },
            
              /*
               * nsIRequestObserver methods
               */
              onStartRequest: function(aRequest, aContext) {
                this._log("onStartRequest");
              },
              onStopRequest: function(aRequest, aContext, aStatus) {
                this._log("onStopRequest (" + aStatus + ")");
                if (aStatus == NS_ERROR_NET_RESET) {
                  this.isConnected = false;
                  this.onConnectionReset();
                }
              },
            
              /*
               * nsITransportEventSink methods
               */
              onTransportStatus: function(aTransport, aStatus, aProgress, aProgressmax) { },
            
              /*
               *****************************************************************************
               ****************************** Private methods ******************************
               *****************************************************************************
               */
              _log: function(str) {
               // Services.console.logStringMessage(str);
               console.log(str);
              },
              _openStreams: function() {
                let threadManager = Cc["@mozilla.org/thread-manager;1"]
                                       .getService(Ci.nsIThreadManager);
                this.transport.setEventSink(this, threadManager.currentThread);
            
                // No limit on the output stream buffer
                this._outputStream = this.transport.openOutputStream(0, // flags
                                                                     this._segmentSize, // Use default segment size
                                                                     -1); // Segment count
                if (!this._outputStream)
                  throw "Error getting output stream.";
            
                this._inputStream = this.transport.openInputStream(0, // flags
                                                                   0, // Use default segment size
                                                                   0); // Use default segment count
                if (!this._inputStream)
                  throw "Error getting input stream.";
            
                // Handle binary mode
                if (this.binaryMode) {
                  this._binaryInputStream = Cc["@mozilla.org/binaryinputstream;1"]
                                               .createInstance(Ci.nsIBinaryInputStream);
                  this._binaryInputStream.setInputStream(this._inputStream);
                } else {
                  this._scriptableInputStream =
                    Cc["@mozilla.org/scriptableinputstream;1"]
                       .createInstance(Ci.nsIScriptableInputStream);
                  this._scriptableInputStream.init(this._inputStream);
                }
            
                this.pump = Cc["@mozilla.org/network/input-stream-pump;1"]
                               .createInstance(Ci.nsIInputStreamPump);
                this.pump.init(this._inputStream, // Data to read
                                -1, // Current offset
                                -1, // Read all data
                                0, // Use default segment size
                                0, // Use default segment length
                                false); // Do not close when done
                this.pump.asyncRead(this, this);
              },
            
              /*
               *****************************************************************************
               ********************* Methods for subtypes to override **********************
               *****************************************************************************
               */
              // Called when a socket is accepted after listening.
              onConnectionHeard: function() {},
              // Called when a connection times out.
              onConnectionTimedOut: function() {},
              // Called when a socket request's network is reset
              onConnectionReset: function() {},
              // Called when ASCII data is available.
              onDataReceived: function(aData) {},
              // Called when binary data is available.
              onBinaryDataReceived: function(aData, aDataLength) {}
            }
            
            // Wrapper to make "this" be the right object inside .onConnectionTimedOut()
            function onTimeOutHelper(connection) {
              connection.onConnectionTimedOut();
            }

module.exports = {
  'mozSocket':mozSocket,
};