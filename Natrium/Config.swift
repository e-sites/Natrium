import Foundation

public class Config {
    public enum EnvironmentType {
        case Dev
        case Staging
        case Production
    }

    public static let environment:EnvironmentType = .Dev

    public static let loggingEnabled:Bool = true
    public static let apiVersion:String = "v1"
    public static let apiBaseURL:String = "http://matchday-api.dev01"
    public static let apiClientID:String = "1_random_id"
    public static let apiClientSecret:String = "secret"
    public static let notificareAppKey:String = "2e79689a0f98edccac88bac0c9cc1d8ad637d8ab0047e63204dcf256cd1a6502"
    public static let notificareAppSecret:String = "3c8f2af8828d6870c483a8270f60045581eb653de1b60775ae5894d59f3bfa5d"
}