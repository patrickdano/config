-- The xmonad configuration of Derek Taylor (DistroTube)
-- mucked around with by Patrick for my needs
-- http://www.youtube.com/c/DistroTube
-- http://www.gitlab.com/dwt1/

------------------------------------------------------------------------
---IMPORTS
------------------------------------------------------------------------
    -- Base
import XMonad
import XMonad.Config.Desktop
import Data.Monoid
import Data.Maybe (isJust)
import System.IO (hPutStrLn)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Utilities
import XMonad.Util.Loggers
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)  
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (safeSpawn, unsafeSpawn, runInTerm, spawnPipe)
import XMonad.Util.SpawnOnce

    -- DBus for xmonad-log
import qualified Codec.Binary.UTF8.String as UTF8 
import Numeric 
import qualified DBus as D 
import qualified DBus.Client as D 
import qualified Data.Map as M
import XMonad.Actions.GroupNavigation
    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, defaultPP, wrap, pad, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.ManageDocks (avoidStruts, docksStartupHook, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog,  doFullFloat, doCenterFloat) 
import XMonad.Hooks.Place (placeHook, withGaps, smart)
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops   -- required for xcomposite in obs to work

    -- Actions
import XMonad.Actions.Minimize (minimizeWindow)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.CopyWindow (kill1, copyToAll, killAllOtherCopies, runOrCopy)
import XMonad.Actions.WindowGo (runOrRaise, raiseMaybe)
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CycleWS (moveTo, shiftTo, WSType(..), nextScreen, prevScreen, shiftNextScreen, shiftPrevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.DynamicWorkspaces (addWorkspacePrompt, removeEmptyWorkspace)
import XMonad.Actions.MouseResize
import qualified XMonad.Actions.ConstrainedResize as Sqr

    -- Layouts modifiers
import XMonad.Layout.PerWorkspace (onWorkspace) 
import XMonad.Layout.Renamed (renamed, Rename(CutWordsLeft, Replace))
import XMonad.Layout.WorkspaceDir
import XMonad.Layout.Spacing (spacing) 
import XMonad.Layout.NoBorders
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.Reflect (reflectVert, reflectHoriz, REFLECTX(..), REFLECTY(..))
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), Toggle(..), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.OneBig
import XMonad.Layout.ThreeColumns
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spiral
import XMonad.Layout.ZoomRow (zoomRow, zoomIn, zoomOut, zoomReset, ZoomMessage(ZoomFullToggle))
import XMonad.Layout.IM (withIM, Property(Role))

    -- Prompts
import XMonad.Prompt (defaultXPConfig, XPConfig(..), XPPosition(Top), Direction1D(..))


---Nord Theme
currentWSHighlight = "#A3BE8C" 
visibleWSHighlight = "#4C566A" 
--base01 = "#586e75" 
--base00 = "#657b83" 
base0 = "#839496" 
--base1 = "#93a1a1" 
--base2 = "#eee8d5" 
--base3 = "#fdf6e3" 
--yellow = "#b58900" 
--orange = "#cb4b16" 
nord_red = "#BF616A" 
--magenta = "#d33682" 
nord_violet = "#B48EAD" 
--blue = "#268bd2" 
--cyan = "#2aa198" 
--green = "#859900" 
--colorGreen = "#259e83" 
nord_lightGray = "#D8DEE9"

------------------------------------------------------------------------
---CONFIG
------------------------------------------------------------------------
--myFont          = "xft:Mononoki Nerd Font:regular:pixelsize=16:antialias=true:hinting=true"
--myFont          = "xft:Font Awesome 5 Free Solid:style=solid:pixelsize=16:antialias=true:hinting=true"
--myFont          = "xft:Consolas:regular:pixelsize=16:antialias=true:hinting=true"
myFont          = "xft:Iosevka Nerd Font:style=regular:pixelsize=16:antialias=true"
myModMask       = mod1Mask  -- Sets modkey to Alt key
myTerminal      = "alacritty"      -- Sets default terminal
myTextEditor    = "nvim"     -- Sets default text editor
myBorderWidth   = 3         -- Sets border width for windows
windowCount     = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

main :: IO ()
main = do
    dbus <- D.connectSession
    D.requestName
        dbus
	(D.busName_ "org.xmonad.Log")     
	[D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
    xmonad $ ewmh desktopConfig
        { manageHook = ( isFullscreen --> doFullFloat ) <+> myManageHook <+> manageHook desktopConfig <+> manageDocks
        , logHook            = dynamicLogWithPP (myLogHook dbus) >> historyHook
        , modMask            = myModMask
        , terminal           = myTerminal
        , startupHook        = myStartupHook
        , layoutHook         = myLayoutHook 
        , workspaces         = myWorkspaces
        , borderWidth        = myBorderWidth
        , normalBorderColor  = "#4C566A"
        , focusedBorderColor = "#5E81AC"
        } `additionalKeysP`         myKeys 

-- Dbus for xmonad-log
myLogHook :: D.Client -> PP 
myLogHook dbus =
    def   
    { ppOutput = dbusOutput dbus   
    , ppCurrent = background currentWSHighlight . wrap "⟪" "⟫" 
    , ppVisible = background visibleWSHighlight   
    , ppUrgent = background nord_red   
    , ppHidden = foreground nord_lightGray   
    , ppSep = " | "
    , ppHiddenNoWindows = foreground base0        -- Hidden workspaces (no windows)
    , ppTitle =  const "" -- foreground nord_violet . shorten 10
    , ppExtras = [windowCount]
    , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
    }   
    where     
        background color = wrap ("%{B" ++ color ++ "} ") " %{B-}"     
	foreground color = wrap ("%{F" ++ color ++ "}") "%{F-}" 

dbusOutput :: D.Client -> String -> IO () 
dbusOutput dbus str = do
  let signal =         
        (D.signal objectPath interfaceName memberName)
	{D.signalBody = [D.toVariant $ UTF8.decodeString str]}   
  D.emit dbus signal   
  where     
      objectPath = D.objectPath_ "/org/xmonad/Log"     
      interfaceName = D.interfaceName_ "org.xmonad.Log"     
      memberName = D.memberName_ "Update"

------------------------------------------------------------------------
---AUTOSTART
------------------------------------------------------------------------
myStartupHook = do
          spawnOnce "nitrogen --restore &" 
          spawnOnce "picom &"
	  spawnOnce "lxsession &"
	  spawnOnce "/home/pdano/.config/polybar/launch_xmonad_polybar.sh"
          --spawnOnce "nm-applet &"
          --spawnOnce "volumeicon &"
          --spawnOnce "trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x292d3e --height 18 &"
          --spawnOnce "emacs --daemon &" 
          --setWMName "LG3D"

------------------------------------------------------------------------
---GRID SELECT
------------------------------------------------------------------------

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                  (0x31,0x2e,0x39) -- lowest inactive bg
                  (0x31,0x2e,0x39) -- highest inactive bg
                  (0x61,0x57,0x72) -- active bg
                  (0xc0,0xa7,0x9a) -- inactive fg
                  (0xff,0xff,0xff) -- active fg
                  
-- gridSelect menu layout
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 30
    , gs_cellwidth    = 200
    , gs_cellpadding  = 8
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }
    
spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = defaultGSConfig

------------------------------------------------------------------------
---KEYBINDINGS
------------------------------------------------------------------------
myKeys =
    -- Xmonad
        [ ("M-C-r", spawn "xmonad --recompile")      -- Recompiles xmonad
        , ("M-q", spawn "xmonad --restart")        -- Restarts xmonad
        , ("M-S-q", io exitSuccess)                  -- Quits xmonad
    
    -- Windows
        , ("M-x", kill1)                           -- Kill the currently focused client
        , ("M-S-a", killAll)                         -- Kill all the windows on current workspace

    -- Floating windows
        , ("M-t", withFocused $ windows . W.sink)  -- Push floating window back to tile.
        , ("M-S-<Delete>", sinkAll)                  -- Push ALL floating windows back to tile.
    
    -- Toggle Full Screen
        , ("M-e", sendMessage $ Toggle NBFULL)


    -- Grid Select
        , (("M-S-t"), spawnSelected'
          [ ("Audacity", "audacity")
          , ("Deadbeef", "deadbeef")
          , ("Emacs", "emacs")
          , ("Firefox", "firefox")
          , ("Geany", "geany")
          , ("Geary", "geary")
          , ("Gimp", "gimp")
          , ("Kdenlive", "kdenlive")
          , ("LibreOffice Impress", "loimpress")
          , ("LibreOffice Writer", "lowriter")
          , ("OBS", "obs")
          , ("PCManFM", "pcmanfm")
          , ("Simple Terminal", "st")
          , ("Steam", "steam")
          , ("Surf Browser",    "surf suckless.org")
          , ("Xonotic", "xonotic-glx")
          ])

        , ("M-S-g", goToSelected $ mygridConfig myColorizer)
        , ("M-S-b", bringSelected $ mygridConfig myColorizer)

    -- Windows navigation
        , ("M-m", windows W.focusMaster)             -- Move focus to the master window
        , ("M-j", windows W.focusDown)               -- Move focus to the next window
        , ("M-k", windows W.focusUp)                 -- Move focus to the prev window
        , ("M-<Return>", windows W.swapMaster)            -- Swap the focused window and the master window
        , ("M-S-j", windows W.swapDown)              -- Swap the focused window with the next window
        , ("M-S-k", windows W.swapUp)                -- Swap the focused window with the prev window
        , ("M-<Backspace>", promote)                 -- Moves focused window to master, all others maintain order
        , ("M1-S-<Tab>", rotSlavesDown)              -- Rotate all windows except master and keep focus in place
        , ("M1-<Tab>", rotAllDown)                 -- Rotate all the windows in the current stack
        , ("M-S-s", windows copyToAll)  
        , ("M-C-s", killAllOtherCopies) 
        
        , ("M-C-M1-<Up>", sendMessage Arrange)
        , ("M-C-M1-<Down>", sendMessage DeArrange)
        , ("M-<Up>", sendMessage (MoveUp 10))             --  Move focused window to up
        , ("M-<Down>", sendMessage (MoveDown 10))         --  Move focused window to down
        , ("M-<Right>", sendMessage (MoveRight 10))       --  Move focused window to right
        , ("M-<Left>", sendMessage (MoveLeft 10))         --  Move focused window to left
        , ("M-S-<Up>", sendMessage (IncreaseUp 10))       --  Increase size of focused window up
        , ("M-S-<Down>", sendMessage (IncreaseDown 10))   --  Increase size of focused window down
        , ("M-S-<Right>", sendMessage (IncreaseRight 10)) --  Increase size of focused window right
        , ("M-S-<Left>", sendMessage (IncreaseLeft 10))   --  Increase size of focused window left
        , ("M-C-<Up>", sendMessage (DecreaseUp 10))       --  Decrease size of focused window up
        , ("M-C-<Down>", sendMessage (DecreaseDown 10))   --  Decrease size of focused window down
        , ("M-C-<Right>", sendMessage (DecreaseRight 10)) --  Decrease size of focused window right
        , ("M-C-<Left>", sendMessage (DecreaseLeft 10))   --  Decrease size of focused window left

    -- Layouts
        , ("M-<Space>", sendMessage NextLayout)                              -- Switch to next layout
        , ("M-S-<Space>", sendMessage ToggleStruts)                          -- Toggles struts
        , ("M-S-n", sendMessage $ Toggle NOBORDERS)                          -- Toggles noborder
        , ("M-S-=", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts) -- Toggles noborder/full
        , ("M-S-f", sendMessage (T.Toggle "float"))
        , ("M-S-x", sendMessage $ Toggle REFLECTX)
        , ("M-S-y", sendMessage $ Toggle REFLECTY)
        , ("M-S-m", sendMessage $ Toggle MIRROR)
        , ("M-<KP_Multiply>", sendMessage (IncMasterN 1))   -- Increase number of clients in the master pane
        , ("M-<KP_Divide>", sendMessage (IncMasterN (-1)))  -- Decrease number of clients in the master pane
        , ("M-S-<KP_Multiply>", increaseLimit)              -- Increase number of windows that can be shown
        , ("M-S-<KP_Divide>", decreaseLimit)                -- Decrease number of windows that can be shown

        , ("M-h", sendMessage Shrink)
        , ("M-l", sendMessage Expand)
        , ("M-C-j", sendMessage MirrorShrink)
        , ("M-C-k", sendMessage MirrorExpand)
        , ("M-S-;", sendMessage zoomReset)
        , ("M-;", sendMessage ZoomFullToggle)

    -- Workspaces
        , ("M-.", nextScreen)                           -- Switch focus to next monitor
        , ("M-,", prevScreen)                           -- Switch focus to prev monitor
        , ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP)       -- Shifts focused window to next workspace
        , ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP)  -- Shifts focused window to previous workspace

    -- Scratchpads
        , ("M-C-<Return>", namedScratchpadAction myScratchPads "terminal")
        , ("M-C-c", namedScratchpadAction myScratchPads "cmus")
        
    -- Open My Preferred Terminal. I also run the FISH shell. Setting FISH as my default shell 
    -- breaks some things so I prefer to just launch "fish" when I open a terminal.
        , ("M-S-<Return>", spawn (myTerminal))
		
    --- Dmenu Scripts (Alt+Ctr+Key)
        , ("M-p", spawn "rofi -show run -modi drun")
        , ("M1-C-e", spawn "./.dmenu/dmenu-edit-configs.sh")
        , ("M1-C-h", spawn "./.dmenu/dmenu-hugo.sh")
        , ("M1-C-m", spawn "./.dmenu/dmenu-sysmon.sh")
        , ("M1-C-p", spawn "passmenu")
        , ("M1-C-s", spawn "./.dmenu/dmenu-surfraw.sh")
        , ("M1-C-/", spawn "./.dmenu/dmenu-scrot.sh")

    --- My Applications (Super+Alt+Key)
    --    , ("M-M1-a", spawn (myTerminal ++ " -e ncpamixer"))
    --    , ("M-M1-b", spawn ("surf www.youtube.com/c/DistroTube/"))
    --    , ("M-M1-c", spawn (myTerminal ++ " -e cmus"))
    --    , ("M-M1-e", spawn (myTerminal ++ " -e neomutt"))
    --    , ("M-M1-f", spawn (myTerminal ++ " -e sh ./.config/vifm/scripts/vifmrun"))
    --    , ("M-M1-i", spawn (myTerminal ++ " -e irssi"))
    --    , ("M-M1-j", spawn (myTerminal ++ " -e joplin"))
    --    , ("M-M1-l", spawn (myTerminal ++ " -e lynx -cfg=~/.lynx/lynx.cfg -lss=~/.lynx/lynx.lss gopher://distro.tube"))
    --    , ("M-M1-m", spawn (myTerminal ++ " -e toot curses"))
    --    , ("M-M1-n", spawn (myTerminal ++ " -e newsboat"))
    --    , ("M-M1-p", spawn (myTerminal ++ " -e pianobar"))
    --    , ("M-M1-r", spawn (myTerminal ++ " -e rtv"))
    --    , ("M-M1-w", spawn (myTerminal ++ " -e wopr report.xml"))
    --    , ("M-M1-y", spawn (myTerminal ++ " -e youtube-viewer"))


    -- Multimedia Keys
        , ("<XF86AudioPlay>", spawn "cmus toggle")
        , ("<XF86AudioPrev>", spawn "cmus prev")
        , ("<XF86AudioNext>", spawn "cmus next")
        -- , ("<XF86AudioMute>",   spawn "amixer set Master toggle")  -- Bug prevents it from toggling correctly in 12.04.
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
        , ("<XF86HomePage>", spawn "firefox")
        , ("<XF86Search>", safeSpawn "firefox" ["https://www.google.com/"])
        , ("<XF86Mail>", runOrRaise "geary" (resource =? "thunderbird"))
        , ("<XF86Calculator>", runOrRaise "gcalctool" (resource =? "gcalctool"))
        , ("<XF86Eject>", spawn "toggleeject")
        , ("<Print>", spawn "scrotd 0")
        ] where nonNSP          = WSIs (return (\ws -> W.tag ws /= "nsp"))
                nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "nsp"))
                
------------------------------------------------------------------------
---WORKSPACES
------------------------------------------------------------------------

--xmobarEscape = concatMap doubleLts
--  where
--        doubleLts '<' = "<<"
--        doubleLts x   = [x]
        
--myWorkspaces :: [String]   
--myWorkspaces = clickable . (map xmobarEscape) 
--               $ ["Main", "Terminals", "Dev", "ws4", "ws5", "ws6", "ws7", "ws8", "Games"]
--
-- where                                                                      
--       clickable l = [ "<action=xdotool key super+" ++ show (n) ++ ">" ++ ws ++ "</action>" |
--                      (i,ws) <- zip [1..9] l,                                        
--                     let n = i ] 
--

myWorkspaces :: [String]   
--myWorkspaces = ["Main", "Terminals", "Dev", "ws4", "ws5", "ws6", "ws7", "ws8", "Games"]
myWorkspaces = ["❶","❷","❸","❹","❺","❻","❼","❽","❾"]

myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
     [
        className =? "Firefox"     --> doShift "<action=xdotool key super+1>www</action>"
      , title =? "Vivaldi"         --> doShift "<action=xdotool key super+2>www</action>"
      , title =? "irssi"           --> doShift "<action=xdotool key super+6>chat</action>"
      , className =? "cmus"        --> doShift "<action=xdotool key super+7>media</action>"
      , className =? "vlc"         --> doShift "<action=xdotool key super+7>media</action>"
      , className =? "Virtualbox"  --> doFloat
      , className =? "Gimp"        --> doFloat
      , className =? "Gimp"        --> doShift "<action=xdotool key super+8>gfx</action>"
      , (className =? "Firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     ] <+> namedScratchpadManageHook myScratchPads

------------------------------------------------------------------------
---LAYOUTS
------------------------------------------------------------------------

myLayoutHook = avoidStruts $ mouseResize $ windowArrange $ T.toggleLayouts floats $ 
               mkToggle (NBFULL ?? NOBORDERS ?? EOT) $ myDefaultLayout
             where 
                 myDefaultLayout = tall ||| grid ||| threeCol ||| threeRow ||| oneBig ||| noBorders monocle ||| space ||| floats ||| spirals


tall       = renamed [Replace "tall"]     $ limitWindows 12 $ spacing 6 $ ResizableTall 1 (3/100) (1/2) []
grid       = renamed [Replace "grid"]     $ limitWindows 12 $ spacing 6 $ mkToggle (single MIRROR) $ Grid (16/10)
threeCol   = renamed [Replace "threeCol"] $ limitWindows 12  $ ThreeCol 1 (3/100) (1/2) 
threeRow   = renamed [Replace "threeRow"] $ limitWindows 12  $ Mirror $ mkToggle (single MIRROR) zoomRow
oneBig     = renamed [Replace "oneBig"]   $ limitWindows 12  $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (5/9) (8/12)
monocle    = renamed [Replace "monocle"]  $ limitWindows 20 $ Full
space      = renamed [Replace "space"]    $ limitWindows 12  $ spacing 12 $ Mirror $ mkToggle (single MIRROR) $ mkToggle (single REFLECTX) $ mkToggle (single REFLECTY) $ OneBig (2/3) (2/3)
floats     = renamed [Replace "floats"]   $ limitWindows 20 $ simplestFloat
spirals     = renamed [Replace "spiral"]   $ limitWindows 10 $ spiral (6/7)

------------------------------------------------------------------------
---SCRATCHPADS
------------------------------------------------------------------------

myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "cmus" spawnCmus findCmus manageCmus  
                ]

    where
    spawnTerm  = myTerminal ++  " -n scratchpad"
    findTerm   = resource =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCmus  = myTerminal ++  " -n cmus 'cmus'"
    findCmus   = resource =? "cmus"
    manageCmus = customFloating $ W.RationalRect l t w h
                 where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w

