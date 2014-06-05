window.resonance = angular.module('resonance',[])
window.resonance.config( [
        '$compileProvider',( $compileProvider ) ->
            $compileProvider.imgSrcSanitizationWhitelist(/^resource:/)
            #compileProvider.imgSrcSanitizationWhitelist(/r/)
    ]);