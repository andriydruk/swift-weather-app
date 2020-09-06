//
// Created by Andriy Druk on 28.06.2020.
//

import Foundation
import WeatherCore
import Swinject
import SwinjectAutoregistration

public class SSLHelper {

    public static func setupCert(basePath: String) {
        // Setup SSL
        let caPath = basePath + "/cacert.pem"
        setenv("URLSessionCertificateAuthorityInfoFile", caPath, 1)
    }
}