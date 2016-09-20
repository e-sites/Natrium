import Foundation

public class Config {
    public enum EnvironmentType : String {
        case staging = "Staging"
        case production = "Production"
    }

    public enum ConfigurationType : String {
        case release = "Release"
        case adhoc = "Adhoc"
        case debug = "Debug"
    }

    public static let environment:EnvironmentType = .staging
    public static let configuration:ConfigurationType = .debug
}
