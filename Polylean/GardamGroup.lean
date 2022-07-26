import Mathlib.Data.Fin.Basic
import Polylean.MetabelianGroup
import Polylean.ProductGroups
import Polylean.EnumDecide
import Polylean.FreeAbelianGroup

/-
We construct the group `P` (the *Promislow* or *Hantzsche–Wendt* group) as a Metabelian group.

This is done via the cocycle construction, using the explicit action and cocycle described in Section 3.1 of Gardam's paper (https://arxiv.org/abs/2102.11818).
-/

namespace P

-- the "kernel" group
abbrev K := ℤ × ℤ × ℤ

instance KGrp : AddCommGroup K := inferInstance

-- the "quotient" group
abbrev Q := Fin 2 × Fin 2

instance QGrp : AddCommGroup Q := inferInstance

-- group elements

abbrev x : K := (1, 0, 0)
abbrev y : K := (0, 1, 0)
abbrev z : K := (0, 0, 1)

@[matchPattern] abbrev e  : Q := (0, 0)
@[matchPattern] abbrev a  : Q := (1, 0)
@[matchPattern] abbrev b  : Q := (0, 1)
@[matchPattern] abbrev ab : Q := (1, 1)

-- the action of `Q` on `K` by automorphisms
-- `id` and `neg` are the identity and negation homomorphisms
@[reducible] def action : Q → (K → K)
  | e => id × id × id
  | a => id × neg × neg
  | b => neg × id × neg
  | ab => neg × neg × id

-- a helper function to easily prove theorems about Q by cases
def Q.rec (P : Q → Sort _) :
  P (⟨0, by decide⟩, ⟨0, by decide⟩) →
  P (⟨0, by decide⟩, ⟨1, by decide⟩) →
  P (⟨1, by decide⟩, ⟨0, by decide⟩) →
  P (⟨1, by decide⟩, ⟨1, by decide⟩) →
  ------------------------------------
  ∀ (q : Q), P q :=
    λ p00 p01 p10 p11 q =>
      match q with
        | (0, 0) => p00
        | (0, 1) => p01
        | (1, 0) => p10
        | (1, 1) => p11


instance : (q : Q) → AddCommGroup.Homomorphism (action q) := by
  apply Q.rec <;> rw [action] <;> exact inferInstance

-- confirm that the above action is an action by automorphisms
-- this is done automatically with the machinery of decidable equality of homomorphisms on free groups
instance : AutAction Q K action :=
  {
    aut_action := inferInstance
    id_action := rfl
    compatibility := by decide
  }


-- the cocycle in the construction
@[reducible] def cocycle : Q → Q → K
  | a , a  => x
  | a , ab => x
  | b , b  => y
  | ab, b  => -y
  | ab, ab => z
  | b , ab => -x + -z
  | ab, a  => -y + z
  | b , a  => -x + y + -z
  | _ , _  => 0

-- confirm that the above function indeed satisfies the cocycle condition
-- this is done fully automatically by previously defined decision procedures
instance P_cocycle : Cocycle cocycle :=
  {
    α := action
    autaction := inferInstance
    cocycleId := rfl
    cocycleCondition := by decide
  }


-- the group `P` constructed via the cocycle construction

abbrev P := K × Q

instance PGrp : Group P := MetabelianGroup.metabeliangroup cocycle

instance : DecidableEq P := inferInstanceAs (DecidableEq (K × Q))

@[simp] theorem Pmul : ∀ k k' : K, ∀ q q' : Q, (k, q) * (k', q') = (k + action q k' + cocycle q q', q + q') :=
  λ k k' q q' => by
    show MetabelianGroup.mul cocycle (k, q) (k', q') = _
    rfl

end P
