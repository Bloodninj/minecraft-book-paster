package;


import haxe.ui.containers.menus.Menu.MenuEvent;
#if cpp
import hx.widgets.Clipboard;
#end
#if js
import js.html.Navigator;
import js.html.Clipboard;
#end
import haxe.ui.locale.LocaleManager;
import haxe.ui.containers.dialogs.Dialogs;
import haxe.ui.events.MouseEvent;
import haxe.ui.containers.VBox;
import Math;

typedef WordData = {pages:Array<String>, linePixCount:Int, wordPixCount:Int};

@:build(haxe.ui.macros.ComponentMacros.build("assets/main-view.xml"))
class App extends VBox {

    var splitText:Array<String>;
    var currentPage:Int = 0;
    var pageCount:Int = 0;

    var SPACE_WIDTH = 3;

    public function new() {
        super();
        // LocaleManager.instance.addStrings("en",new Map<String,String>(),"assets/en.properties");
        LocaleManager.instance.language = "en";
        // js.Browser.document.getElementById("appContainer").appendChild(this.element);
        inputTextfield.text = "Et sequi voluptatum voluptatibus. Velit doloremque ipsum autem perspiciatis. Et voluptatem est dolor. Voluptatem molestiae est earum. Repellendus et aut animi impedit. Quia velit quis quas at suscipit.\nSunt aliquid perspiciatis sit sit. Veniam facere culpa excepturi facere accusamus omnis quis ex. Vitae iusto et occaecati. Laborum aut molestiae possimus.\nSit quisquam enim sed natus autem. Veritatis est totam qui debitis tempore. Dolorem aliquid iusto omnis et et.";
        // pageCountLabel.hidden = true;
        // errorLabel.hidden = true;
    }

    @:bind(convertBookButton, MouseEvent.CLICK)
    private function onConvertBookButton(e:MouseEvent) {
        splitText = getSplitLines(inputTextfield.text, pageCount);
        outputTextfield.text = splitText[currentPage];
        // LocaleManager.instance.refreshAll();
        currentPage = 0;
        updatePages();
    }

    @:bind(firstPageButton, MouseEvent.CLICK)
    private function onFirstCopyButton(e:MouseEvent) {
        if (splitText != null)
        {
            currentPage = 0;
            updatePages();
        }
        copyOutputText();
    }

    @:bind(previousPageButton, MouseEvent.CLICK)
    private function onPreviousCopyButton(e:MouseEvent) {
        if (splitText != null)
        {
            currentPage--;
            updatePages();
        }
        copyOutputText();
    }

    @:bind(copyPageButton, MouseEvent.CLICK)
    private function onCopyPageButton(e:MouseEvent) {
        copyOutputText();
    }

    @:bind(nextPageButton, MouseEvent.CLICK)
    private function onNextCopyButton(e:MouseEvent) {
        if (splitText != null)
        {
            currentPage++;
            updatePages();
        }
        copyOutputText();
    }

    @:bind(lastPageButton, MouseEvent.CLICK)
    private function onLastCopyButton(e:MouseEvent) {
        if (splitText != null)
        {
            currentPage = pageCount;
            updatePages();
        }
        copyOutputText();
    }

    function updatePages() {
        currentPage = cast Math.max(0,Math.min(currentPage,pageCount));
        // pageCountLabel.text = 'Page ${currentPage+1} of ${pageCount+1}';
        outputTextfield.text = splitText[currentPage];
        LocaleManager.instance.refreshAll();
    }

    /**
        Takes an input string and optional width and returns a string which has been
        split with newlines to fit the width, based on Minecraft font character width.
        @param  input       The string to be split
        @param  maxWidth    Maximum line width (in pixels)
        @return String containing the split lines.
    **/
    function getSplitLines(input:String, pageCount:Int, ?maxWidth:Int = 114):Array<String> {
        var pages:Array<String> = [];
        var pageCount:Int = 0;
        var newLineCount:Int = 0;
        var linePixCount:Int = 0;
        var wordPixCount:Int = 0;
        var paragraphs = [];

        // Reset vars
        pageCount = 0;
        currentPage = 0;
        splitText = [];
        this.pageCount = 0;

        paragraphs = input.split("\n");
        pages[this.pageCount] = "";
        for (i in 0...paragraphs.length)
        {
            var pg = paragraphs[i];
            trace('==NEW PARAGRAPH==:\n$pg');
            // linePixCount = 0;
            var words:Array<String> = pg.split(" ");
            if (words.length > 1)
            {
                for (j in 0...words.length)
                {
                    var word = words[j];
                    if (word != "\n" && word != "" && word != " ")
                    {
                        wordPixCount = 0;
                        trace('+ Word \"$word\" has ${word.length} characters');
                        wordPixCount = getWordPxWidth(word);

                        trace('It is $wordPixCount pixels long.');
                        trace('linePixCount is $linePixCount, wordPixCount is $wordPixCount.');
                        trace('Current newLineCount is $newLineCount.');

                        if (linePixCount + SPACE_WIDTH + wordPixCount > maxWidth)
                        {
                            trace("Word can't fit on current line");                
                            pages[currentPage] += " "; // should be \n but doesn't paste right
                            newLineCount++;
                            trace('\n--- NEW LINE COUNT is $newLineCount---\n');
                            if (newLineCount > 14) {
                                trace('Page count is ${this.pageCount}, increasing it.');
                                this.pageCount++;
                                trace('\n\n---NEW PAGE COUNT is ${this.pageCount}---\n\n');
                                this.currentPage = this.pageCount;
                                trace('new currentPage is ${this.currentPage}.');
                                pages[currentPage] = "";
                                newLineCount = 0;
                                trace('\n--- NEW LINE COUNT is $newLineCount---\n');
                            }
                            linePixCount = 0;
                            trace('New linePixCount is $linePixCount.');
                        }
                        
                        if (linePixCount + wordPixCount + SPACE_WIDTH <= maxWidth)
                        {
                            trace('Word can fit');
                            var returnData:WordData;
                            if (linePixCount == 0) {
                                trace('Adding word \"${word}\"');
                                returnData = addWordToPage(word,pages,words,j,linePixCount,wordPixCount);
                            }
                            else {
                                trace('Adding word \"${word}\" with space');
                                returnData = addWordToPage(" "+word,pages,words,j,linePixCount,wordPixCount);
                            }
                            pages = returnData.pages;
                            linePixCount = returnData.linePixCount;
                            wordPixCount = returnData.wordPixCount;
                        }
                        // else if (linePixCount + wordPixCount < maxWidth)
                        // {
                        //     trace('Word can fit with no space');
                        //     pages[currentPage] += word;
                        //     linePixCount += wordPixCount + 3;
                        // }
                        // if (linePixCount + 3 <= maxWidth)
                        // {
                        //     pages[currentPage] += " ";
                        //     linePixCount += 3;
                        // }
                        
                        
                    }
                    trace('New linePixCount is $linePixCount.');
                }
            }
            // if (newLineCount < 14)
            // {
                // }
                pages[currentPage] += "\n";
                newLineCount++;
                trace('\n--- NEW LINE COUNT is $newLineCount---\n');
                if (newLineCount > 14) {
                    trace('Page count is ${this.pageCount}, increasing it.');
                    this.pageCount++;
                    trace('\n\n---NEW PAGE COUNT is ${this.pageCount}---\n\n');
                    this.currentPage = this.pageCount;
                    trace('new currentPage is ${this.currentPage}.');
                    pages[currentPage] = "";
                    newLineCount = 0;
                    trace('\n--- NEW LINE COUNT is $newLineCount---\n');
                }
                linePixCount = 0;
                trace('New linePixCount is $linePixCount.');
        }
        pageCount = this.pageCount;
        if (this.pageCount > 50)
        {
            errorLabel.customStyle.fontBold = true;
            errorLabel.text = LocaleManager.instance.lookupString("UI.error.tooLongBedrockOnly");
            if (this.pageCount > 100)
            {
                errorLabel.text = LocaleManager.instance.lookupString("UI.error.tooLongBoth");
                }
        }
        else {
            errorLabel.customStyle.fontBold = false;
        }

        trace("\n=== DONE ===\n");
        return pages;
    }

    function addWordToPage(currentWord:String,pages:Array<String>,words:Array<String>,wordIndex:Int,linePixCount:Int,wordPixCount:Int):WordData {
        pages[this.pageCount] += currentWord;
        linePixCount += wordPixCount;
        return {pages: pages, linePixCount: linePixCount, wordPixCount: wordPixCount};
    }

    function getWordPxWidth(word:String):Int {
        var count = 0;
        for (c in word.split("")) {
            count += getCharWidth(c);
            // count++;
        }
        count += word.length * 2;
        return count;
    }

    /**
        Get the width of a character in the default Minecraft font.
        @param  char    Char to check width of
        @return Width of the character (in pixels)
    **/
    function getCharWidth(char:String):Int {
        switch(char) {
            case "!","\'",",",".",":",";","i","|":
                {
                    return 1;
                }
            case "\n","`","l":
                {
                    return 2;
                }
            case "\"","(",")","*","I","[","]","t","{","}"," ":
                {
                    return 3;
                }
            case "<",">","f","k":
                {
                    return 4;
                }
            case "@","~":
                {
                    return 6;
                }
            default:
                {
                    return 5;
                }
        }
    }

    function copyOutputText() {
        #if js
        js.Browser.navigator.clipboard.writeText(outputTextfield.text).then((v) -> {
            trace('Copied to clipboard!');
        },
        (v)-> {
            trace('Clipboard failed...');
        });
        #end
        #if cpp
        Clipboard.textData = outputTextfield.text;
        #end
    }

    @:bind(menuBar, MenuEvent.MENU_SELECTED)
    private function handleMenuItems(e:MenuEvent) {
        trace('Attempting to open file dialogue');
        switch (e.menuItem.id) {
            case "openFileMenuItem": {
                Dialogs.openTextFile(LocaleManager.instance.lookupString("menu.file.openFile"),[{extension: "txt", label: LocaleManager.instance.lookupString("menu.file.textFile")}],
                    (info) -> {
                        try {
                            inputTextfield.text = info.text;
                        } catch (e) {
                            errorLabel.text = e.message;
                        }
                    });
                }
            case "languageMenuEnglishItem": switchLocale("en");
            case "languageMenuGermanItem": switchLocale("de-DE");
            default: {}
        }
    }


    function switchLocale(localeString:String) {
        LocaleManager.instance.language = localeString;
        LocaleManager.instance.refreshAll(); 
    }

}