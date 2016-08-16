import XMonad

import Data.Map    (fromList)
import Data.Monoid (mappend)

import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Config.Xfce
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig

main = xmonad =<< statusBar myPP toggleStrutsKey myConfig

-- -- Command to launch the bar.
-- myBar = "xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }

-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)

-- Main configuration, override the defaults to your liking.
myConfig = ewmh defaultConfig {
  workspaces = myWorkspaces
  , manageHook = myManageHook
  , layoutHook = avoidStruts $ layoutHook defaultConfig
  , modMask = mod4Mask
  , startupHook = setWMName "LG3D"
  } `additionalKeysP` myKeys

myManageHook = composeAll
               [
                 isFullscreen --> doFullFloat
               , (role =? "gimp-toolbox" <||> role =? "gimp-image-window") --> (ask >>= doF . W.sink)
               ]
  where role = stringProperty "WM_WINDOW_ROLE"

myWorkspaces = map show [ 1 .. 9 :: Int ]

myKeys = [
    ( "M-S-q"   , spawn "xfce4-session-logout")
  , ( "M-S-s"   , spawn "xfce4-session-logout --suspend")
  , ( "M-S-l"   , spawn "xscreensaver-command --lock")
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
