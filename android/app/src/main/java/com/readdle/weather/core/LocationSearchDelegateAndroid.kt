// Generated using JavaSwift codegen by Sourcery
// DO NOT EDIT

package com.readdle.weather.core;

import com.readdle.codegen.anotation.SwiftCallbackFunc
import com.readdle.codegen.anotation.SwiftDelegate

@SwiftDelegate(protocols = ["LocationSearchDelegate"])
interface LocationSearchDelegateAndroid {

    @SwiftCallbackFunc("onSuggestionStateChanged(state:)")
	fun onSuggestionStateChanged(state: ArrayList<Location>)

	@SwiftCallbackFunc("onError(errorDescription:)")
	fun onError(errorDescription: String)

    companion object {
        
    }

}