package;

import haxe.ui.events.MouseEvent;
import haxe.ui.containers.VBox;
import Math;

@:build(haxe.ui.macros.ComponentMacros.build("assets/main-view.xml"))
class App extends VBox {

    var splitText:Array<String>;
    var currentPage:Int = 0;
    var pageCount:Int = 0;

    public function new() {
        super();
        // js.Browser.document.getElementById("appContainer").appendChild(this.element);
        textField.text = "Et sequi voluptatum voluptatibus. Velit doloremque ipsum autem perspiciatis. Et voluptatem est dolor. Voluptatem molestiae est earum. Repellendus et aut animi impedit. Quia velit quis quas at suscipit.\nSunt aliquid perspiciatis sit sit. Veniam facere culpa excepturi facere accusamus omnis quis ex. Vitae iusto et occaecati. Laborum aut molestiae possimus.\nSit quisquam enim sed natus autem. Veritatis est totam qui debitis tempore. Dolorem aliquid iusto omnis et et.";
        pageCountLabel.hidden = true;
        errorLabel.hidden = true;
    }

    @:bind(button2, MouseEvent.CLICK)
    private function onMyButton(e:MouseEvent) {
        splitText = getSplitLines(textField.text, pageCount);
        textField2.text = splitText[currentPage];
        pageCountLabel.hidden = false;
        updatePages();
    }

    @:bind(previousPageButton, MouseEvent.CLICK)
    private function onPreviousPageButton(e:MouseEvent) {
        if (splitText != null)
        {
            currentPage--;
            updatePages();
        }
    }

    @:bind(nextPageButton, MouseEvent.CLICK)
    private function onNextPageButton(e:MouseEvent) {
        if (splitText != null)
        {
            currentPage++;
            updatePages();
        }
    }

    function updatePages() {
        currentPage = cast Math.max(0,Math.min(currentPage,pageCount));
        pageCountLabel.text = 'Page ${currentPage+1} of ${pageCount+1}';
        textField2.text = splitText[currentPage];
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
        var wordIndex:Int = 0;
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
            wordIndex = 0;
            linePixCount = 0;
            if (newLineCount < 14) {
                var words:Array<String> = pg.split(" ");
                if (words.length > 1)
                {
                    for (j in 0...words.length)
                    {
                        var word = words[j];
                        wordIndex++;
                        if (word != "\n" && word != "" && word != " ")
                        {
                            wordPixCount = 0;
                            trace('+ Word \"$word\" has ${word.length} characters');
                            for (x in 0...word.length)
                            {
                                wordPixCount += getCharWidth(word.charAt(x));
                                if (x < word.length-1)
                                {
                                    wordPixCount++;
                                }
                            }
                            trace('It is $wordPixCount pixels long.');
                            trace('linePixCount is $linePixCount, wordPixCount is $wordPixCount.');
                            trace('Current newLineCount is $newLineCount.');
                            if (linePixCount + wordPixCount + 3 < maxWidth)
                            {
                                trace('Word can fit plus a space');
                                pages[this.pageCount] += word;
                                linePixCount += wordPixCount;
                                // Don't go out of bounds of words array
                                if (j+1 <= words.length - 1)
                                {
                                    // Check to see if next word will end up on a new line
                                    // If so, don't add trailing space
                                    var nextWord:String = words[j+1];
                                    var nextWordPixCount:Int = 0;
                                    trace('The next word \"$nextWord\" has ${nextWord.length} characters');
                                    for (x in 0...nextWord.length)
                                    {
                                        nextWordPixCount += getCharWidth(word.charAt(x));
                                        if (x < nextWord.length-1)
                                        {
                                            nextWordPixCount++;
                                        }
                                    }
                                    trace('The next word $nextWord is $nextWordPixCount pixels wide, making the line ${linePixCount + 3 + nextWordPixCount} pixels wide.');
                                    if (linePixCount + 3 + nextWordPixCount > maxWidth)
                                    {
                                        trace('Next word will end up on a new line, not adding trailing space.');
                                    }
                                    else
                                    {
                                        pages[this.pageCount] += " ";
                                        linePixCount += 3;
                                    }
                                }
                            }
                            // else if (linePixCount + wordPixCount < maxWidth)
                            // {
                            //     trace('Word can fit with no space');
                            //     pages[this.pageCount] += word;
                            //     linePixCount += wordPixCount + 3;
                            // }
                            else
                            {
                                trace("Word can't fit on current line");                
                                newLineCount++;
                                trace('\n--- NEW LINE COUNT is $newLineCount---\n');
                                if (newLineCount == 14) {
                                    trace('Page count is ${this.pageCount}, increasing it.');
                                    this.pageCount++;
                                    trace('\n\n---NEW PAGE COUNT is ${this.pageCount}---\n\n');
                                    pages[this.pageCount] = "";
                                    newLineCount = 0;
                                    linePixCount = 0;
                                }
                                if (newLineCount > 0)
                                {
                                    linePixCount = wordPixCount + 3;
                                    pages[this.pageCount] += "\n" + word + " ";
                                }
                                else
                                {
                                    linePixCount = wordPixCount + 3;
                                    pages[this.pageCount] += word + " ";
                                }
                            }
                        }
                        trace('New linePixCount is $linePixCount.');
                    }
                }
            }
            if (newLineCount < 13)
            {
                pages[this.pageCount] += "\n";
                newLineCount++;
            }
        }
        pageCount = this.pageCount;
        if (this.pageCount > 50)
        {
            errorLabel.hidden = false;
            errorLabel.text = "This text will be too long to paste into one book in Bedrock.";
            pageCountLabel.customStyle.color = 0xFF8600;
            pageCountLabel.invalidateComponentStyle();
            if (this.pageCount > 100)
            {
                errorLabel.text = "This text will be too long to paste into one book in both Java and Bedrock.";
                pageCountLabel.customStyle.color = 0xFF0000;
                pageCountLabel.invalidateComponentStyle();
            }
        }
        else
        {
            errorLabel.hidden = true;
            pageCountLabel.customStyle.color = 0x000000;
            pageCountLabel.invalidateComponentStyle();
        }
        trace("\n=== DONE ===\n");
        return pages;
    }

    /**
        Get the width of a character in the default Minecraft font.
        @param  char    Char to check width of
        @return Width of the character (in pixels)
    **/
    function getCharWidth(char:String):Int {
        switch(char) {
            case "!","\'",",",".",":",";","i","|"," ":
                {
                    return 1;
                }
            case "\n","`","l":
                {
                    return 2;
                }
            case "\"","(",")","*","I","[","]","t","{","}":
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
}