import Foundation

public class Config {
    public enum EnvironmentType: String {
        case staging = "Staging"
        case production = "Production"
    }

    public enum ConfigurationType: String {
        case debug = "Debug"
        case release = "Release"
        case adhoc = "Adhoc"
    }

    public static let environment: EnvironmentType = .production
    public static let configuration: ConfigurationType = .debug
}
