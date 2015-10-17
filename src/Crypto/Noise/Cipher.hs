{-# LANGUAGE TypeFamilies #-}
----------------------------------------------------------------
-- |
-- Module      : Crypto.Noise.Cipher
-- Maintainer  : John Galt <centromere@users.noreply.github.com>
-- Stability   : experimental
-- Portability : POSIX

module Crypto.Noise.Cipher
  ( -- * Classes
    Cipher(..),
    -- * Types
    Plaintext(..),
    AssocData(..)
  ) where

import Crypto.Noise.Types

class Cipher c where
  data Ciphertext   c :: *
  data SymmetricKey c :: *
  data ChainingKey  c :: *
  data Nonce        c :: *
  data Digest       c :: *

  cipherName        :: c -> ScrubbedBytes
  cipherEncrypt     :: SymmetricKey c -> Nonce c -> AssocData -> Plaintext -> Ciphertext c
  cipherDecrypt     :: SymmetricKey c -> Nonce c -> AssocData -> Ciphertext c -> Maybe Plaintext
  cipherZeroNonce   :: Nonce c
  cipherIncNonce    :: Nonce c -> Nonce c
  cipherHash        :: ScrubbedBytes -> Digest c
  cipherHKDF        :: ChainingKey c -> ScrubbedBytes -> (ChainingKey c, SymmetricKey c)
  cipherHashToSK    :: Digest c -> SymmetricKey c
  cipherHashToCK    :: Digest c -> ChainingKey c
  cipherChainToSym  :: ChainingKey c -> SymmetricKey c
  cipherHashToBytes :: Digest c -> ScrubbedBytes
  cipherTextToBytes :: Ciphertext c -> ScrubbedBytes
  cipherBytesToText :: ScrubbedBytes -> Ciphertext c

newtype Plaintext = Plaintext ScrubbedBytes
newtype AssocData = AssocData ScrubbedBytes
