public class Theme {
    let color: Dictionary<String, String>;
    let fontFamily: String;

    let fontWeight: Dictionary<String, String>

    convenience public init() {
        self.init(color: [:], fontFamily: "", fontWeight: [:] )
    }

    public init(color userColors: Dictionary<String, String>?, fontFamily userFontFamily: String?, fontWeight userFontWeight: Dictionary<String, String>?) {
        color = [
            "primary": "",
            "secondary": "",
            "error": "",
            "textPrimary": "",
            "textSecondary": "",
            "textInteractive": ""
        ].merging(userColors ?? [:]) { (_, userProp) in userProp }
        fontFamily = userFontFamily ?? ""
        fontWeight = [
            "light": "300",
            "regular": "400",
            "medium": "500",
            "semibold": "600",
            "bold": "700",
        ].merging(userFontWeight ?? [:]) { (_, userProp) in userProp }

    }
}
