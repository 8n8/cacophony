{-# LANGUAGE OverloadedStrings #-}
module SymmetricHandshakeState where

import Imports
import Instances()

import Control.Monad.State (runState, state)

import Data.ByteString (ByteString)

import Crypto.Noise.Cipher
import Crypto.Noise.Cipher.ChaChaPoly1305
import Crypto.Noise.Internal.SymmetricHandshakeState
import Crypto.Noise.Types

shs :: SymmetricHandshakeState ChaChaPoly1305
shs = symmetricHandshake $ convert ("handshake name" :: ByteString)

roundTripProp :: Plaintext -> Property
roundTripProp pt = (decrypt . encrypt) pt === pt
  where
    encrypt p = encryptAndHash p shs
    decrypt (ct, _) = fst $ decryptAndHash (cipherBytesToText ct) shs

manyRoundTripsProp :: [Plaintext] -> Property
manyRoundTripsProp pts = (fst . manyDecrypts . manyEncrypts) pts === pts
  where
    encrypt = encryptAndHash
    decrypt = decryptAndHash . cipherBytesToText
    doMany f xs = runState . mapM (state . f) $ xs
    manyEncrypts xs = doMany encrypt xs shs
    manyDecrypts (cts, _) = doMany decrypt cts shs

tests :: TestTree
tests = testGroup "SymmetricHandshake"
  [ testProperty "ChaChaPoly1305 one roundtrip" $ property roundTripProp
  , testProperty "ChaChaPoly1305 many roundtrips" $ property manyRoundTripsProp
  ]
