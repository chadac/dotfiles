import XMonad

import Data.Map    (fromList)
import Data.Monoid (mappend)

import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.CopyWindow
import XMonad.Config.Xfce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Prompt
import XMonad.Prompt.Input
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

myBar = "/home/chad/.cabal/bin/xmobar"
myPP = xmobarPP {
    ppCurrent = xmobarColor "#b58900" "" . wrap "<" ">"
  , ppVisible = xmobarColor "#93a1a1" "" . wrap "(" ")"
  , ppUrgent = xmobarColor "#dc322f" "#b58900"
  , ppTitle = xmobarColor "#859900" "" . shorten 40
}
toggleStrutsKey XConfig { XMonad.modMask = modMask } = (modMask, xK_b)

main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig
  {
    startupHook = startupHook myConfig >> setWMName "LG3D"
    , logHook = ewmhDesktopsLogHook
  }

-- Main configuration, override the defaults to your liking.
myConfig = ewmh defaultConfig {
  manageHook = pbManageHook <+> myManageHook
                            <+> manageHook defaultConfig
  , terminal = "xfce4-terminal"
  , workspaces = myWorkspaces
  , layoutHook = avoidStruts $ layoutHook defaultConfig
  , handleEventHook = mconcat [
      ewmhDesktopsEventHook
      , docksEventHook
      ]
  , modMask = mod4Mask
  } `additionalKeysP` myKeys

-- ManageHook --
pbManageHook :: ManageHook
pbManageHook = composeAll $ concat
    [ [ manageDocks ]
    , [ manageHook defaultConfig ]
    , [ isDialog --> doCenterFloat ]
    , [ isFullscreen --> doFullFloat ]
    , [ fmap not isDialog --> doF avoidMaster ]
    ]

myManageHook = composeAll
               [
                 isFullscreen --> doFullFloat
               , (className =? "Xfce4-notifyd") --> doF W.focusDown -- <+> doF copyToAll
               , (role =? "gimp-toolbox" <||> role =? "gimp-image-window") --> (ask >>= doF . W.sink)
               , (role =? "xpanel") --> (ask >>= doF . W.sink)
               , manageDocks
               ]
  where role = stringProperty "WM_WINDOW_ROLE"

-- Helpers --
-- avoidMaster:  Avoid the master window, but otherwise manage new windows normally
avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
    W.Stack t [] (r:rs) -> W.Stack t [r] rs
    otherwise -> c

myWorkspaces = map show [ 1 .. 9 :: Int ]

-- Keys
myKeys = [
  ( "M-S-l"   , spawn "xflock4")
  , ( "M-S-s" , spawn "xfce4-session-logout --suspend")
  , ( "M-S-q"   , spawn "xfce4-session-logout --logout --fast")
    -- other additional keys
  ] ++ -- (++) is needed here because the following list comprehension
         -- is a list, not a single key binding. Simply adding it to the
         -- list of key bindings would result in something like [ b1, b2,
         -- [ b3, b4, b5 ] ] resulting in a type error. (Lists must
         -- contain items all of the same type.)
    [ (otherModMasks ++ "M-" ++ [key], action tag)
      | (tag, key)  <- zip myWorkspaces "123456789"
      , (otherModMasks, action) <- [ ("", windows . W.view) -- was W.greedyView
                                      , ("S-", windows . W.shift)]
                                      ]
