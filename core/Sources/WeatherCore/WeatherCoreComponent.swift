//
// Created by Andriy Druk on 20.04.2020.
//

import Foundation
import Cleanse

public struct WeatherCoreFactory {
    public let weatherViewModelFactory: Factory<LocationWeatherViewModel.Seed>
    public let searchViewModelFactory: Factory<LocationSearchViewModel.Seed>
}

public struct WeatherCoreComponent: Cleanse.RootComponent {
    public typealias Root = WeatherCoreFactory
    public typealias Scope = Singleton
    
    public static var basePath: String = ""

    public static func configure(binder: Binder<Singleton>) {
        binder.bind(WeatherProvider.self).to(value: MetaWeatherProvider())
        binder.bind(WeatherDatabase.self).to(value: JSONStorage(basePath: basePath))
        binder.bindFactory(LocationSearchViewModel.self).with(LocationSearchViewModel.Seed.self).to(factory: LocationSearchViewModel.init)
        binder.bindFactory(LocationWeatherViewModel.self).with(LocationWeatherViewModel.Seed.self).to(factory: LocationWeatherViewModel.init)
    }

    public static func configureRoot(binder bind: ReceiptBinder<Root>) -> BindingReceipt<Root> {
        return bind.to(factory: WeatherCoreFactory.init)
    }
    
    public static func prepare(withBasePath basePath: String) -> WeatherCoreComponent.Type {
        self.basePath = basePath
        return WeatherCoreComponent.self
    }
}

extension LocationSearchViewModel {
    
    public struct Seed: AssistedFactory {
        public typealias Seed = LocationSearchDelegate
        public typealias Element = LocationSearchViewModel
    }
    
    convenience init(provider: WeatherProvider, assisted: Assisted<LocationSearchDelegate>) {
        self.init(provider: provider, delegate: assisted.get())
    }
    
}

extension LocationWeatherViewModel {
    
    public struct Seed: AssistedFactory {
        public typealias Seed = LocationWeatherViewModelDelegate
        public typealias Element = LocationWeatherViewModel
    }
    
    convenience init(db: WeatherDatabase, provider: WeatherProvider, assisted: Assisted<LocationWeatherViewModelDelegate>) {
        self.init(db: db, provider: provider, delegate: assisted.get())
    }
    
}
