{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RebindableSyntax #-}
{-# OPTIONS_GHC -fno-warn-missing-fields #-}
{-# OPTIONS_GHC -fno-warn-unticked-promoted-constructors #-}
{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}

module Simplex.Messaging.Scenarios where

import Control.Protocol
import Control.XMonad.Do
import Data.Singletons
import Data.String
import Simplex.Messaging.Protocol
import Simplex.Messaging.Types
import Prelude hiding ((>>), (>>=))

r :: Sing Recipient
r = SRecipient

b :: Sing Broker
b = SBroker

s :: Sing Sender
s = SSender

-- Establish simplex messaging connection and send first message
establishConnection :: SimplexProtocol '[None, None, None] '[Secured, Secured, Secured] ()
establishConnection = do
  r ->: b $ CreateConn "BODbZxmtKUUF1l8pj4nVjQ"
  r ->: b $ Subscribe "RU"
  r ->: s $ SendInvite Invitation {connId = "SU"}
  s ->: b $ ConfirmConn "SU" "encrypted"
  b ->: r $ PushConfirm "RU" Message {msgId = "abc", msg = "XPaVEVNunkYKqqK0dnAT5Q"}
  r ->: b $ SecureConn "RU" "XPaVEVNunkYKqqK0dnAT5Q"
  r ->: b $ DeleteMsg "RU" "abc"
  s ->: b $ SendMsg "SU" "welcome" -- welcome message
  b ->: r $ PushMsg "RU" Message {msgId = "def", msg = "welcome"}
  r ->: b $ DeleteMsg "RU" "def"
  -- The connection is established ("Secured"), sending the message
  s ->: b $ SendMsg "SU" "hello there"
  b ->: r $ PushMsg "RU" Message {msgId = "ghi", msg = "hello there"}
  r ->: b $ DeleteMsg "RU" "ghi"
  r ->: b $ Unsubscribe "RU"
