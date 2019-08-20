{-# LANGUAGE OverloadedLists #-}
-----------------------------------------------------------------------------
-- |
-- Module     : Algebra.Graph.Test.Label
-- License    : MIT (see the file LICENSE)
-- Stability  : experimental
--
-- Testsuite for "Algebra.Graph.Label".
-----------------------------------------------------------------------------
module Algebra.Graph.Test.Label where
{-
  (
    -- * Testsuite
    testLabel
    ) where
-}

import Algebra.Graph.Test
import Algebra.Graph.Label
import Data.Monoid

type UnaryFn a = a -> a
type BinaryFn a = a -> a -> a
type Plus a = BinaryFn a
type Mult a = BinaryFn a
type Star a = UnaryFn a
type Identity a = a
type Zero a = a
type One a = a
type Annhilator a = a

associative :: Eq a => BinaryFn a -> a -> a -> a -> Property
associative f a b c = (a `f` b) `f` c == a `f` (b `f` c) // "Associative property"

commutative :: Eq a => BinaryFn a -> a -> a -> Property
commutative f a b = a `f` b == b `f` a // "Commutative property"

idempotance :: Eq a => BinaryFn a -> a -> Property
idempotance f a = a `f` a == a // "Idempotence property"

annhilator :: Eq a => BinaryFn a -> Annhilator a -> a -> Property
annhilator f z a = conjoin
  [ a `f` z == z // "Annhilator property"
  , z `f` a == z // "Annhilator property" ]

star' :: Eq a => Plus a -> Mult a -> One a -> Star a -> a -> Property
star' p m o s a = conjoin
  [ s a == o `p` (a `m` s a) // "Star property"
  , s a == o `p` (s a `m` a) // "Star property" ]

leftDistribute :: Eq a => Plus a -> Mult a -> a -> a -> a -> Property
leftDistribute p m a b c = a `m` (b `p` c) == (a `m` b) `p` (a `m` c) // "Left distribute"

rightDistribute :: Eq a => Plus a -> Mult a -> a -> a -> a -> Property
rightDistribute p m a b c = (a `p` b) `m` c == (a `m` c) `p` (b `m` c) // "Right distribute"

distribute :: Eq a => Plus a -> Mult a -> a -> a -> a -> Property
distribute p m a b c = conjoin
  [ leftDistribute p m a b c
  , rightDistribute p m a b c ]

identity :: Eq a => BinaryFn a -> Identity a -> a -> Property
identity f e a = conjoin
  [ a `f` e == a // "Identity"
  , e `f` a == a // "Identity" ]

semigroup :: Eq a => BinaryFn a -> a -> a -> a -> Property
semigroup = associative

monoid :: Eq a => BinaryFn a -> Identity a -> a -> a -> a -> Property
monoid f e a b c = conjoin
  [ associative f a b c
  , identity f e a ]

commutativeMonoid :: Eq a => BinaryFn a -> Identity a -> a -> a -> a -> Property
commutativeMonoid f e a b c = conjoin
  [ monoid f e a b c
  , commutative f a b ]

semiring :: Eq a => Plus a -> Zero a -> Mult a -> One a -> a -> a -> a -> Property
semiring p z m o a b c = conjoin
  [ commutativeMonoid p z a b c
  , monoid m o a b c
  , distribute p m a b c
  , annhilator m z a ]

dioid :: Eq a => Plus a -> Zero a -> Mult a -> One a -> a -> a -> a -> Property
dioid p z m o a b c = conjoin
  [ semiring p z m o a b c
  , idempotance p a ]

starSemiring :: Eq a => Plus a -> Zero a -> Mult a -> One a -> Star a -> a -> a -> a -> Property
starSemiring p z m o s a b c = conjoin
  [ semiring p z m o a b c
  , star' p m o s a ]

testSemiring :: (Eq a, Semiring a) => a -> a -> a -> Property
testSemiring = semiring (<+>) zero (<.>) one

testDioid :: (Eq a, Dioid a) => a -> a -> a -> Property
testDioid = dioid (<+>) zero (<.>) one

testStarSemiring :: (Eq a, StarSemiring a) => a -> a -> a -> Property
testStarSemiring = starSemiring (<+>) zero (<.>) one star

testLabel :: IO ()
testLabel = do
    putStrLn "\n============ Any ============"
    test "Semiring"     $ \(a :: Any) b c -> testSemiring a b c
    test "StarSemiring" $ \(a :: Any) b c -> testStarSemiring a b c
    test "Dioid"        $ \(a :: Any) b c -> testDioid a b c


