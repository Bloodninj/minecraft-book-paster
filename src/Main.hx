package ;

import haxe.ui.Toolkit;
import haxe.ui.HaxeUIApp;

class Main {
    public static function main() {
        Toolkit.init();
        var app = new HaxeUIApp();
        // Toolkit.theme = "native";
        app.ready(function() {
            app.ready(function() {
                app.addComponent(new App());
                app.start();
            });
        });
    }
}
