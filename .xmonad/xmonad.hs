import XMonad

import Data.Map    (fromList)
import Data.Monoid (mappend)

import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

main = xmonad =<< xmobar myConfig
  {
    startupHook = startupHook myConfig >> setWMName "LG3D"
    , logHook = ewmhDesktopsLogHook
  }

-- Main configuration, override the defaults to your liking.
myConfig = ewmh defaultConfig {
  manageHook = pbManageHook <+> myManageHook
                            <+> manageDocks
                            <+> manageHook defaultConfig
  , terminal = "xfce4-terminal"
  , workspaces = myWorkspaces
  , layoutHook = avoidStruts $ layoutHook defaultConfig
  , handleEventHook = ewmhDesktopsEventHook
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
               , (role =? "gimp-toolbox" <||> role =? "gimp-image-window") --> (ask >>= doF . W.sink)
               ]
  where role = stringProperty "WM_WINDOW_ROLE"

-- Helpers --
-- avoidMaster:  Avoid the master window, but otherwise manage new windows normally
avoidMaster :: W.StackSet i l a s sd -> W.StackSet i l a s sd
avoidMaster = W.modify' $ \c -> case c of
    W.Stack t [] (r:rs) -> W.Stack t [r] rs
    otherwise -> c

myWorkspaces = map show [ 1 .. 9 :: Int ]

myKeys = [
  ( "M-S-l"   , spawn "xscreensaver-command --lock")
  , ( "M-p"     , spawn "dmenu_run -b")
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
