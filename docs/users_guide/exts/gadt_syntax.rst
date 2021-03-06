.. _gadt-style:

Declaring data types with explicit constructor signatures
---------------------------------------------------------

.. extension:: GADTSyntax
    :shortdesc: Enable generalised algebraic data type syntax.

    :since: 7.2.1

    Allow the use of GADT syntax in data type definitions (but not GADTs
    themselves; for this see :extension:`GADTs`)

When the ``GADTSyntax`` extension is enabled, GHC allows you to declare
an algebraic data type by giving the type signatures of constructors
explicitly. For example: ::

      data Maybe a where
          Nothing :: Maybe a
          Just    :: a -> Maybe a

The form is called a "GADT-style declaration" because Generalised
Algebraic Data Types, described in :ref:`gadt`, can only be declared
using this form.

Notice that GADT-style syntax generalises existential types
(:ref:`existential-quantification`). For example, these two declarations
are equivalent: ::

      data Foo = forall a. MkFoo a (a -> Bool)
      data Foo' where { MKFoo :: a -> (a->Bool) -> Foo' }

Any data type that can be declared in standard Haskell 98 syntax can
also be declared using GADT-style syntax. The choice is largely
stylistic, but GADT-style declarations differ in one important respect:
they treat class constraints on the data constructors differently.
Specifically, if the constructor is given a type-class context, that
context is made available by pattern matching. For example: ::

      data Set a where
        MkSet :: Eq a => [a] -> Set a

      makeSet :: Eq a => [a] -> Set a
      makeSet xs = MkSet (nub xs)

      insert :: a -> Set a -> Set a
      insert a (MkSet as) | a `elem` as = MkSet as
                          | otherwise   = MkSet (a:as)

A use of ``MkSet`` as a constructor (e.g. in the definition of
``makeSet``) gives rise to a ``(Eq a)`` constraint, as you would expect.
The new feature is that pattern-matching on ``MkSet`` (as in the
definition of ``insert``) makes *available* an ``(Eq a)`` context. In
implementation terms, the ``MkSet`` constructor has a hidden field that
stores the ``(Eq a)`` dictionary that is passed to ``MkSet``; so when
pattern-matching that dictionary becomes available for the right-hand
side of the match. In the example, the equality dictionary is used to
satisfy the equality constraint generated by the call to ``elem``, so
that the type of ``insert`` itself has no ``Eq`` constraint.

For example, one possible application is to reify dictionaries: ::

       data NumInst a where
         MkNumInst :: Num a => NumInst a

       intInst :: NumInst Int
       intInst = MkNumInst

       plus :: NumInst a -> a -> a -> a
       plus MkNumInst p q = p + q

Here, a value of type ``NumInst a`` is equivalent to an explicit
``(Num a)`` dictionary.

All this applies to constructors declared using the syntax of
:ref:`existential-with-context`. For example, the ``NumInst`` data type
above could equivalently be declared like this: ::

       data NumInst a
          = Num a => MkNumInst (NumInst a)

Notice that, unlike the situation when declaring an existential, there
is no ``forall``, because the ``Num`` constrains the data type's
universally quantified type variable ``a``. A constructor may have both
universal and existential type variables: for example, the following two
declarations are equivalent: ::

       data T1 a
        = forall b. (Num a, Eq b) => MkT1 a b
       data T2 a where
        MkT2 :: (Num a, Eq b) => a -> b -> T2 a

All this behaviour contrasts with Haskell 98's peculiar treatment of
contexts on a data type declaration (Section 4.2.1 of the Haskell 98
Report). In Haskell 98 the definition ::

      data Eq a => Set' a = MkSet' [a]

gives ``MkSet'`` the same type as ``MkSet`` above. But instead of
*making available* an ``(Eq a)`` constraint, pattern-matching on
``MkSet'`` *requires* an ``(Eq a)`` constraint! GHC faithfully
implements this behaviour, odd though it is. But for GADT-style
declarations, GHC's behaviour is much more useful, as well as much more
intuitive.

The rest of this section gives further details about GADT-style data
type declarations.

-  The result type of each data constructor must begin with the type
   constructor being defined. If the result type of all constructors has
   the form ``T a1 ... an``, where ``a1 ... an`` are distinct type
   variables, then the data type is *ordinary*; otherwise is a
   *generalised* data type (:ref:`gadt`).

-  As with other type signatures, you can give a single signature for
   several data constructors. In this example we give a single signature
   for ``T1`` and ``T2``: ::

         data T a where
           T1,T2 :: a -> T a
           T3 :: T a

-  The type signature of each constructor is independent, and is
   implicitly universally quantified as usual. In particular, the type
   variable(s) in the "``data T a where``" header have no scope, and
   different constructors may have different universally-quantified type
   variables: ::

         data T a where        -- The 'a' has no scope
           T1,T2 :: b -> T b   -- Means forall b. b -> T b
           T3 :: T a           -- Means forall a. T a

-  A constructor signature may mention type class constraints, which can
   differ for different constructors. For example, this is fine: ::

         data T a where
           T1 :: Eq b => b -> b -> T b
           T2 :: (Show c, Ix c) => c -> [c] -> T c

   When pattern matching, these constraints are made available to
   discharge constraints in the body of the match. For example: ::

         f :: T a -> String
         f (T1 x y) | x==y      = "yes"
                    | otherwise = "no"
         f (T2 a b)             = show a

   Note that ``f`` is not overloaded; the ``Eq`` constraint arising from
   the use of ``==`` is discharged by the pattern match on ``T1`` and
   similarly the ``Show`` constraint arising from the use of ``show``.

-  Unlike a Haskell-98-style data type declaration, the type variable(s)
   in the "``data Set a where``" header have no scope. Indeed, one can
   write a kind signature instead: ::

         data Set :: Type -> Type where ...

   or even a mixture of the two: ::

         data Bar a :: (Type -> Type) -> Type where ...

   The type variables (if given) may be explicitly kinded, so we could
   also write the header for ``Foo`` like this: ::

         data Bar a (b :: Type -> Type) where ...

-  You can use strictness annotations, in the obvious places in the
   constructor type: ::

         data Term a where
             Lit    :: !Int -> Term Int
             If     :: Term Bool -> !(Term a) -> !(Term a) -> Term a
             Pair   :: Term a -> Term b -> Term (a,b)

-  You can use a ``deriving`` clause on a GADT-style data type
   declaration. For example, these two declarations are equivalent ::

         data Maybe1 a where {
             Nothing1 :: Maybe1 a ;
             Just1    :: a -> Maybe1 a
           } deriving( Eq, Ord )

         data Maybe2 a = Nothing2 | Just2 a
              deriving( Eq, Ord )

-  The type signature may have quantified type variables that do not
   appear in the result type: ::

         data Foo where
            MkFoo :: a -> (a->Bool) -> Foo
            Nil   :: Foo

   Here the type variable ``a`` does not appear in the result type of
   either constructor. Although it is universally quantified in the type
   of the constructor, such a type variable is often called
   "existential". Indeed, the above declaration declares precisely the
   same type as the ``data Foo`` in :ref:`existential-quantification`.

   The type may contain a class context too, of course: ::

         data Showable where
           MkShowable :: Show a => a -> Showable

-  You can use record syntax on a GADT-style data type declaration: ::

         data Person where
             Adult :: { name :: String, children :: [Person] } -> Person
             Child :: Show a => { name :: !String, funny :: a } -> Person

   As usual, for every constructor that has a field ``f``, the type of
   field ``f`` must be the same (modulo alpha conversion). The ``Child``
   constructor above shows that the signature may have a context,
   existentially-quantified variables, and strictness annotations, just
   as in the non-record case. (NB: the "type" that follows the
   double-colon is not really a type, because of the record syntax and
   strictness annotations. A "type" of this form can appear only in a
   constructor signature.)

-  Record updates are allowed with GADT-style declarations, only fields
   that have the following property: the type of the field mentions no
   existential type variables.

-  As in the case of existentials declared using the Haskell-98-like
   record syntax (:ref:`existential-records`), record-selector functions
   are generated only for those fields that have well-typed selectors.
   Here is the example of that section, in GADT-style syntax: ::

       data Counter a where
           NewCounter :: { _this    :: self
                         , _inc     :: self -> self
                         , _display :: self -> IO ()
                         , tag      :: a
                         } -> Counter a

   As before, only one selector function is generated here, that for
   ``tag``. Nevertheless, you can still use all the field names in
   pattern matching and record construction.

-  In a GADT-style data type declaration there is no obvious way to
   specify that a data constructor should be infix, which makes a
   difference if you derive ``Show`` for the type. (Data constructors
   declared infix are displayed infix by the derived ``show``.) So GHC
   implements the following design: a data constructor declared in a
   GADT-style data type declaration is displayed infix by ``Show`` iff
   (a) it is an operator symbol, (b) it has two arguments, (c) it has a
   programmer-supplied fixity declaration. For example

   ::

          infix 6 (:--:)
          data T a where
            (:--:) :: Int -> Bool -> T Int


