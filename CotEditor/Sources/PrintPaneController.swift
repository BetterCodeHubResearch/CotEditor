/*
 
 PrintPaneController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2014-04-18.
 
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2014-2017 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 https://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Cocoa

final class PrintPaneController: NSViewController {
    
    // MARK: Private Properties
    
    @IBOutlet fileprivate private(set) weak var fontField: NSTextField?
    @IBOutlet private weak var colorPopupButton: NSPopUpButton?
    
    
    
    // MARK: -
    // MARK: View Controller Methods
    
    /// apply current settings to UI
    override func viewWillAppear() {
        
        self.setupFontFamilyNameAndSize()
        self.setupColorMenu()
    }
    
    
    
    // MARK: Action Messages
    
    /// color setting did update
    @IBAction func changePrintTheme(_ sender: NSPopUpButton) {
        
        let index = sender.indexOfSelectedItem
        let theme = (index > 2) ? sender.titleOfSelectedItem : nil  // do not set theme on `Black and White` and `same as document's setting`
        
        UserDefaults.standard[.printTheme] = theme
        UserDefaults.standard[.printColorIndex] = index
    }
    
    
    
    // MARK: Private Methods
    
    /// update popup menu for color setting
    private func setupColorMenu() {
        
        let index = UserDefaults.standard[.printColorIndex]
        let themeName = UserDefaults.standard[.printTheme]
        let themeNames = ThemeManager.shared.settingNames
        
        guard let popupButton = self.colorPopupButton else { return }
        
        popupButton.removeAllItems()
        
        // build popup button
        popupButton.addItem(withTitle: ThemeName.blackAndWhite)
        popupButton.addItem(withTitle: NSLocalizedString("Same as Document’s Setting", comment: ""))
        popupButton.menu?.addItem(.separator())
        
        popupButton.addItem(withTitle: NSLocalizedString("Theme", comment: ""))
        popupButton.lastItem?.isEnabled = false
        
        for name in themeNames {
            popupButton.addItem(withTitle: name)
            popupButton.lastItem?.indentationLevel = 1
        }
        
        // select menu
        popupButton.selectItem(at: 0)  // black and white (default)
        if let themeName = themeName {
            if themeNames.contains(themeName) {
                popupButton.selectItem(withTitle: themeName)
            } else if index == 1 {
                popupButton.selectItem(at: 1)  // same as document
            }
        }
    }
    
}



// MARK: - Font Setting

extension PrintPaneController {
    
    // MARK: View Controller Methods
    
    override func viewWillDisappear() {
        
        super.viewWillDisappear()
        
        // detach a possible font panel's target set in `showFonts()`
        if NSFontManager.shared.target === self {
            NSFontManager.shared.target = nil
        }
    }
    
    
    
    // MARK: Action Messages
    
    /// show font panel
    @IBAction func showFonts(_ sender: Any?) {
        
        guard let font = NSFont(name: UserDefaults.standard[.printFontName]!,
                                size: UserDefaults.standard[.printFontSize]) else { return }
        
        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        NSFontManager.shared.orderFrontFontPanel(sender)
        NSFontManager.shared.target = self
    }
    
    
    /// font in font panel did update
    @IBAction override func changeFont(_ sender: Any?) {
        
        guard let fontManager = sender as? NSFontManager else { return }
        
        let newFont = fontManager.convert(.systemFont(ofSize: 0))
        
        UserDefaults.standard[.printFontName] = newFont.fontName
        UserDefaults.standard[.printFontSize] = newFont.pointSize
        
        self.setupFontFamilyNameAndSize()
    }
    
    
    
    // MARK: Private Methods
    
    /// display font name and size in the font field
    fileprivate func setupFontFamilyNameAndSize() {
        
        let name = UserDefaults.standard[.printFontName]!
        let size = UserDefaults.standard[.printFontSize]
        let maxDisplaySize = NSFont.systemFontSize(for: .regular)
        
        guard
            let font = NSFont(name: name, size: size),
            let displayFont = NSFont(name: name, size: min(size, maxDisplaySize)),
            let fontField = self.fontField
            else { return }
        
        let displayName = font.displayName ?? font.fontName
        
        fontField.stringValue = displayName + " " + String.localizedStringWithFormat("%g", size)
        fontField.font = displayFont
    }
    
}
