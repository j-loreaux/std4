/-
Copyright (c) 2022 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Std.Data.Fin.Basic
import Std.Data.Nat.Lemmas
import Std.Tactic.Ext
import Std.Tactic.Simpa
import Std.Tactic.NormCast.Lemmas

namespace Fin

/-- If you actually have an element of `Fin n`, then the `n` is always positive -/
theorem size_pos (i : Fin n) : 0 < n := Nat.lt_of_le_of_lt (Nat.zero_le _) i.2

theorem mod_def (a m : Fin n) : a % m = Fin.mk ((a % m) % n) (Nat.mod_lt _ a.size_pos) := rfl

theorem mul_def (a b : Fin n) : a * b = Fin.mk ((a * b) % n) (Nat.mod_lt _ a.size_pos) := rfl

theorem sub_def (a b : Fin n) : a - b = Fin.mk ((a + (n - b)) % n) (Nat.mod_lt _ a.size_pos) := rfl

theorem size_pos' : ∀ [Nonempty (Fin n)], 0 < n | ⟨i⟩ => i.size_pos

@[simp] theorem is_lt (a : Fin n) : (a : Nat) < n := a.2

theorem pos_iff_nonempty {n : Nat} : 0 < n ↔ Nonempty (Fin n) :=
  ⟨fun h => ⟨⟨0, h⟩⟩, fun ⟨i⟩ => i.pos⟩

/-! ### coercions and constructions -/

@[simp] protected theorem eta (a : Fin n) (h : a < n) : (⟨a, h⟩ : Fin n) = a := by cases a; rfl

@[ext] theorem ext {a b : Fin n} (h : (a : Nat) = b) : a = b := eq_of_val_eq h

theorem val_inj {a b : Fin n} : a.1 = b.1 ↔ a = b := ⟨Fin.eq_of_val_eq, Fin.val_eq_of_eq⟩

theorem ext_iff {a b : Fin n} : a = b ↔ a.1 = b.1 := val_inj.symm

theorem val_ne_iff {a b : Fin n} : a.1 ≠ b.1 ↔ a ≠ b := not_congr val_inj

theorem exists_iff {p : Fin n → Prop} : (∃ i, p i) ↔ ∃ i h, p ⟨i, h⟩ :=
  ⟨fun ⟨⟨i, hi⟩, hpi⟩ => ⟨i, hi, hpi⟩, fun ⟨i, hi, hpi⟩ => ⟨⟨i, hi⟩, hpi⟩⟩

theorem forall_iff {p : Fin n → Prop} : (∀ i, p i) ↔ ∀ i h, p ⟨i, h⟩ :=
  ⟨fun h i hi => h ⟨i, hi⟩, fun h ⟨i, hi⟩ => h i hi⟩

protected theorem mk.inj_iff {n a b : Nat} {ha : a < n} {hb : b < n} :
    (⟨a, ha⟩ : Fin n) = ⟨b, hb⟩ ↔ a = b := ext_iff

theorem val_mk {m n : Nat} (h : m < n) : (⟨m, h⟩ : Fin n).val = m := rfl

theorem eq_mk_iff_val_eq {a : Fin n} {k : Nat} {hk : k < n} :
    a = ⟨k, hk⟩ ↔ (a : Nat) = k := ext_iff

theorem mk_val (i : Fin n) : (⟨i, i.isLt⟩ : Fin n) = i := Fin.eta ..

@[simp] theorem ofNat'_zero_val : (Fin.ofNat' 0 h).val = 0 := Nat.zero_mod _

@[simp] theorem mod_val (a b : Fin n) : (a % b).val = a.val % b.val :=
  Nat.mod_eq_of_lt (Nat.lt_of_le_of_lt (Nat.mod_le ..) a.2)

@[simp] theorem div_val (a b : Fin n) : (a / b).val = a.val / b.val :=
  Nat.mod_eq_of_lt (Nat.lt_of_le_of_lt (Nat.div_le_self ..) a.2)

@[simp] theorem modn_val (a : Fin n) (b : Nat) : (a.modn b).val = a.val % b :=
  Nat.mod_eq_of_lt (Nat.lt_of_le_of_lt (Nat.mod_le ..) a.2)

theorem ite_val {n : Nat} {c : Prop} [Decidable c] {x : c → Fin n} (y : ¬c → Fin n) :
    (if h : c then x h else y h).val = if h : c then (x h).val else (y h).val := by
  by_cases c <;> simp [*]

theorem dite_val {n : Nat} {c : Prop} [Decidable c] {x y : Fin n} :
    (if c then x else y).val = if c then x.val else y.val := by
  by_cases c <;> simp [*]

/-! ### order -/

theorem le_def {a b : Fin n} : a ≤ b ↔ a.1 ≤ b.1 := .rfl

theorem lt_def {a b : Fin n} : a < b ↔ a.1 < b.1 := .rfl

@[simp] protected theorem not_le {a b : Fin n} : ¬ a ≤ b ↔ b < a := Nat.not_le

@[simp] protected theorem not_lt {a b : Fin n} : ¬ a < b ↔ b ≤ a := Nat.not_lt

protected theorem ne_of_lt {a b : Fin n} (h : a < b) : a ≠ b := Fin.ne_of_val_ne (Nat.ne_of_lt h)

protected theorem ne_of_gt {a b : Fin n} (h : a < b) : b ≠ a := Fin.ne_of_val_ne (Nat.ne_of_gt h)

theorem is_le (i : Fin (n + 1)) : i ≤ n := Nat.le_of_lt_succ i.is_lt

@[simp] theorem is_le' {a : Fin n} : a ≤ n := Nat.le_of_lt a.is_lt

theorem mk_lt_of_lt_val {b : Fin n} {a : Nat} (h : a < b) :
    (⟨a, Nat.lt_trans h b.is_lt⟩ : Fin n) < b := h

theorem mk_le_of_le_val {b : Fin n} {a : Nat} (h : a ≤ b) :
    (⟨a, Nat.lt_of_le_of_lt h b.is_lt⟩ : Fin n) ≤ b := h

@[simp] theorem mk_le_mk {x y : Nat} {hx hy} : (⟨x, hx⟩ : Fin n) ≤ ⟨y, hy⟩ ↔ x ≤ y := .rfl

@[simp] theorem mk_lt_mk {x y : Nat} {hx hy} : (⟨x, hx⟩ : Fin n) < ⟨y, hy⟩ ↔ x < y := .rfl

@[simp] theorem val_zero (n : Nat) : (0 : Fin (n + 1)).1 = 0 := rfl

@[simp] theorem mk_zero : (⟨0, Nat.succ_pos n⟩ : Fin (n + 1)) = 0 := rfl

@[simp] theorem zero_le (a : Fin (n + 1)) : 0 ≤ a := Nat.zero_le a.val

theorem zero_lt_one : (0 : Fin (n + 2)) < 1 := Nat.zero_lt_one

@[simp] theorem not_lt_zero (a : Fin (n + 1)) : ¬a < 0 := fun.

theorem pos_iff_ne_zero {a : Fin (n + 1)} : 0 < a ↔ a ≠ 0 := by
  rw [lt_def, val_zero, Nat.pos_iff_ne_zero, ← val_ne_iff]; rfl

theorem eq_zero_or_eq_succ {n : Nat} : ∀ i : Fin (n + 1), i = 0 ∨ ∃ j : Fin n, i = j.succ
  | 0 => .inl rfl
  | ⟨j + 1, h⟩ => .inr ⟨⟨j, Nat.lt_of_succ_lt_succ h⟩, rfl⟩

theorem eq_succ_of_ne_zero {n : Nat} {i : Fin (n + 1)} (hi : i ≠ 0) : ∃ j : Fin n, i = j.succ :=
  (eq_zero_or_eq_succ i).resolve_left hi

@[simp] theorem val_rev (i : Fin n) : rev i = n - (i + 1) := rfl

@[simp] theorem rev_rev (i : Fin n) : rev (rev i) = i := ext <| by
  rw [val_rev, val_rev, ← Nat.sub_sub, Nat.sub_sub_self (by exact i.2), Nat.add_sub_cancel]

@[simp] theorem rev_le_rev {i j : Fin n} : rev i ≤ rev j ↔ j ≤ i := by
  simp only [le_def, val_rev, Nat.sub_le_sub_iff_left (Nat.succ_le.2 j.is_lt)]
  exact Nat.succ_le_succ_iff

@[simp] theorem rev_inj {i j : Fin n} : rev i = rev j ↔ i = j :=
  ⟨fun h => by simpa using congrArg rev h, congrArg _⟩

theorem rev_eq {n a : Nat} (i : Fin (n + 1)) (h : n = a + i) :
    rev i = ⟨a, Nat.lt_succ_of_le (h ▸ Nat.le_add_right ..)⟩ := by
  ext; dsimp
  conv => lhs; congr; rw [h]
  rw [Nat.add_assoc, Nat.add_sub_cancel]

@[simp] theorem rev_lt_rev {i j : Fin n} : rev i < rev j ↔ j < i := by
  rw [← Fin.not_le, ← Fin.not_le, rev_le_rev]

@[simp, norm_cast] theorem val_last (n : Nat) : last n = n := rfl

theorem le_last (i : Fin (n + 1)) : i ≤ last n := Nat.le_of_lt_succ i.is_lt

theorem last_pos : (0 : Fin (n + 2)) < last (n + 1) := Nat.succ_pos _

theorem eq_last_of_not_lt {i : Fin (n + 1)} (h : ¬(i : Nat) < n) : i = last n :=
  ext <| Nat.le_antisymm (le_last i) (Nat.not_lt.1 h)

theorem val_lt_last {i : Fin (n + 1)} : i ≠ last n → (i : Nat) < n :=
  Decidable.not_imp_comm.1 eq_last_of_not_lt

/-! ### addition, numerals, and coercion from Nat -/

@[simp] theorem val_one (n : Nat) : (1 : Fin (n + 2)).val = 1 := rfl

@[simp] theorem mk_one : (⟨1, Nat.succ_lt_succ (Nat.succ_pos n)⟩ : Fin (n + 2)) = (1 : Fin _) := rfl

theorem subsingleton_iff_le_one : Subsingleton (Fin n) ↔ n ≤ 1 := by
  (match n with | 0 | 1 | n+2 => ?_) <;> simp
  · exact ⟨fun.⟩
  · exact ⟨fun ⟨0, _⟩ ⟨0, _⟩ => rfl⟩
  · exact iff_of_false (fun h => Fin.ne_of_lt zero_lt_one (h.elim ..)) (of_decide_eq_false rfl)

instance subsingleton_zero : Subsingleton (Fin 0) := subsingleton_iff_le_one.2 (by decide)

instance subsingleton_one : Subsingleton (Fin 1) := subsingleton_iff_le_one.2 (by decide)

theorem fin_one_eq_zero (a : Fin 1) : a = 0 := Subsingleton.elim a 0

theorem add_def (a b : Fin n) : a + b = Fin.mk ((a + b) % n) (Nat.mod_lt _ a.size_pos) := rfl

theorem val_add (a b : Fin n) : (a + b).val = (a.val + b.val) % n := rfl

theorem val_add_one_of_lt {n : Nat} {i : Fin n.succ} (h : i < last _) : (i + 1).1 = i + 1 := by
  match n with
  | 0 => cases h
  | n+1 => rw [val_add, val_one, Nat.mod_eq_of_lt (by exact Nat.succ_lt_succ h)]

@[simp] theorem last_add_one : ∀ n, last n + 1 = 0
  | 0 => rfl
  | n + 1 => by ext; rw [val_add, val_zero, val_last, val_one, Nat.mod_self]

theorem val_add_one {n : Nat} (i : Fin (n + 1)) :
    ((i + 1 : Fin (n + 1)) : Nat) = if i = last _ then (0 : Nat) else i + 1 := by
  match Nat.eq_or_lt_of_le (le_last i) with
  | .inl h => cases Fin.eq_of_val_eq h; simp
  | .inr h => simpa [Fin.ne_of_lt h] using val_add_one_of_lt h

@[simp] theorem val_two {n : Nat} : (2 : Fin (n + 3)).val = 2 := rfl

theorem add_one_pos (i : Fin (n + 1)) (h : i < Fin.last n) : (0 : Fin (n + 1)) < i + 1 := by
  match n with
  | 0 => cases h
  | n+1 =>
    rw [Fin.lt_def, val_last, ← Nat.add_lt_add_iff_right 1] at h
    rw [Fin.lt_def, val_add, val_zero, val_one, Nat.mod_eq_of_lt h]
    exact Nat.zero_lt_succ _

theorem one_pos : (0 : Fin (n + 2)) < 1 := Nat.succ_pos 0

theorem zero_ne_one : (0 : Fin (n + 2)) ≠ 1 := Fin.ne_of_lt one_pos

/-! ### succ and casts into larger Fin types -/

@[simp] theorem val_succ (j : Fin n) : (j.succ : Nat) = j + 1 := by cases j; simp [Fin.succ]

@[simp] theorem succ_pos (a : Fin n) : (0 : Fin (n + 1)) < a.succ := by
  simp [Fin.lt_def, Nat.succ_pos]

@[simp] theorem succ_le_succ_iff {a b : Fin n} : a.succ ≤ b.succ ↔ a ≤ b := Nat.succ_le_succ_iff

@[simp] theorem succ_lt_succ_iff {a b : Fin n} : a.succ < b.succ ↔ a < b := Nat.succ_lt_succ_iff

@[simp] theorem succ_inj {a b : Fin n} : a.succ = b.succ ↔ a = b := by
  refine ⟨fun h => ext ?_, congrArg _⟩
  apply Nat.le_antisymm <;> exact succ_le_succ_iff.1 (h ▸ Nat.le_refl _)

theorem succ_ne_zero {n} : ∀ k : Fin n, Fin.succ k ≠ 0
  | ⟨k, _⟩, heq => Nat.succ_ne_zero k <| ext_iff.1 heq

@[simp] theorem succ_zero_eq_one : Fin.succ (0 : Fin (n + 1)) = 1 := rfl

/-- Version of `succ_one_eq_two` to be used by `dsimp` -/
@[simp] theorem succ_one_eq_two : Fin.succ (1 : Fin (n + 2)) = 2 := rfl

@[simp] theorem succ_mk (n i : Nat) (h : i < n) :
    Fin.succ ⟨i, h⟩ = ⟨i + 1, Nat.succ_lt_succ h⟩ := rfl

theorem mk_succ_pos (i : Nat) (h : i < n) :
    (0 : Fin (n + 1)) < ⟨i.succ, Nat.add_lt_add_right h 1⟩ := by
  rw [lt_def, val_zero]; exact Nat.succ_pos i

theorem one_lt_succ_succ (a : Fin n) : (1 : Fin (n + 2)) < a.succ.succ := by
  let n+1 := n
  rw [← succ_zero_eq_one, succ_lt_succ_iff]; exact succ_pos a

@[simp] theorem add_one_lt_iff {n : Nat} {k : Fin (n + 2)} : k + 1 < k ↔ k = last _ := by
  simp only [lt_def, val_add, val_last, ext_iff]
  let ⟨k, hk⟩ := k
  match Nat.eq_or_lt_of_le (Nat.le_of_lt_succ hk) with
  | .inl h => cases h; simp [Nat.succ_pos]
  | .inr hk' => simp [Nat.ne_of_lt hk', Nat.mod_eq_of_lt (Nat.succ_lt_succ hk'), Nat.le_succ]

@[simp] theorem add_one_le_iff {n : Nat} : ∀ {k : Fin (n + 1)}, k + 1 ≤ k ↔ k = last _ := by
  match n with
  | 0 =>
    intro (k : Fin 1)
    exact iff_of_true (Subsingleton.elim (α := Fin 1) (k+1) _ ▸ Nat.le_refl _) (fin_one_eq_zero ..)
  | n + 1 =>
    intro (k : Fin (n+2))
    rw [← add_one_lt_iff, lt_def, le_def, Nat.lt_iff_le_and_ne, and_iff_left]
    rw [val_add_one]
    split <;> simp [*, (Nat.succ_ne_zero _).symm, Nat.ne_of_gt (Nat.lt_succ_self _)]

@[simp] theorem last_le_iff {n : Nat} {k : Fin (n + 1)} : last n ≤ k ↔ k = last n := by
  rw [ext_iff, Nat.le_antisymm_iff, le_def, and_iff_right (by apply le_last)]

@[simp] theorem lt_add_one_iff {n : Nat} {k : Fin (n + 1)} : k < k + 1 ↔ k < last n := by
  rw [← Decidable.not_iff_not]; simp

@[simp] theorem le_zero_iff {n : Nat} {k : Fin (n + 1)} : k ≤ 0 ↔ k = 0 :=
  ⟨fun h => Fin.eq_of_val_eq <| Nat.eq_zero_of_le_zero h, (· ▸ Nat.le_refl _)⟩

theorem succ_succ_ne_one (a : Fin n) : Fin.succ (Fin.succ a) ≠ 1 :=
  Fin.ne_of_gt (one_lt_succ_succ a)

@[simp] theorem coe_castLT (i : Fin m) (h : i.1 < n) : (castLT i h : Nat) = i := rfl

@[simp] theorem castLT_mk (i n m : Nat) (hn : i < n) (hm : i < m) : castLT ⟨i, hn⟩ hm = ⟨i, hm⟩ :=
  rfl

@[simp] theorem coe_castLE (h : n ≤ m) (i : Fin n) : (castLE h i : Nat) = i := rfl

@[simp] theorem castLE_mk (i n m : Nat) (hn : i < n) (h : n ≤ m) :
    castLE h ⟨i, hn⟩ = ⟨i, Nat.lt_of_lt_of_le hn h⟩ := rfl

@[simp] theorem castLE_zero {n m : Nat} (h : n.succ ≤ m.succ) : castLE h 0 = 0 := by simp [ext_iff]

@[simp] theorem castLE_succ {m n : Nat} (h : m + 1 ≤ n + 1) (i : Fin m) :
    castLE h i.succ = (castLE (Nat.succ_le_succ_iff.mp h) i).succ := by simp [ext_iff]

@[simp] theorem castLE_castLE {k m n} (km : k ≤ m) (mn : m ≤ n) (i : Fin k) :
    Fin.castLE mn (Fin.castLE km i) = Fin.castLE (Nat.le_trans km mn) i :=
  Fin.ext (by simp only [coe_castLE])

@[simp] theorem castLE_comp_castLE {k m n} (km : k ≤ m) (mn : m ≤ n) :
    Fin.castLE mn ∘ Fin.castLE km = Fin.castLE (Nat.le_trans km mn) :=
  funext (castLE_castLE km mn)

@[simp] theorem coe_cast (h : n = m) (i : Fin n) : (cast h i : Nat) = i := rfl

@[simp] theorem cast_last {n' : Nat} {h : n + 1 = n' + 1} : cast h (last n) = last n' :=
  ext (by rw [coe_cast, val_last, val_last, Nat.succ.inj h])

@[simp] theorem cast_mk (h : n = m) (i : Nat) (hn : i < n) : cast h ⟨i, hn⟩ = ⟨i, h ▸ hn⟩ := rfl

@[simp] theorem cast_trans {k : Nat} (h : n = m) (h' : m = k) {i : Fin n} :
    cast h' (cast h i) = cast (Eq.trans h h') i := rfl

theorem castLE_of_eq {m n : Nat} (h : m = n) {h' : m ≤ n} : castLE h' = Fin.cast h := rfl

@[simp] theorem coe_castAdd (m : Nat) (i : Fin n) : (castAdd m i : Nat) = i := rfl

@[simp] theorem castAdd_zero : (castAdd 0 : Fin n → Fin (n + 0)) = cast rfl := rfl

theorem castAdd_lt {m : Nat} (n : Nat) (i : Fin m) : (castAdd n i : Nat) < m := by simp

@[simp] theorem castAdd_mk (m : Nat) (i : Nat) (h : i < n) :
    castAdd m ⟨i, h⟩ = ⟨i, Nat.lt_add_right i n m h⟩ := rfl

@[simp] theorem castAdd_castLT (m : Nat) (i : Fin (n + m)) (hi : i.val < n) :
    castAdd m (castLT i hi) = i := rfl

@[simp] theorem castLT_castAdd (m : Nat) (i : Fin n) :
    castLT (castAdd m i) (castAdd_lt m i) = i := rfl

/-- For rewriting in the reverse direction, see `Fin.cast_castAdd_left`. -/
theorem castAdd_cast {n n' : Nat} (m : Nat) (i : Fin n') (h : n' = n) :
    castAdd m (Fin.cast h i) = Fin.cast (congrArg (. + m) h) (castAdd m i) := ext rfl

theorem cast_castAdd_left {n n' m : Nat} (i : Fin n') (h : n' + m = n + m) :
    cast h (castAdd m i) = castAdd m (cast (Nat.add_right_cancel h) i) := rfl

@[simp] theorem cast_castAdd_right {n m m' : Nat} (i : Fin n) (h : n + m' = n + m) :
    cast h (castAdd m' i) = castAdd m i := rfl

theorem castAdd_castAdd {m n p : Nat} (i : Fin m) :
    castAdd p (castAdd n i) = cast (Nat.add_assoc ..).symm (castAdd (n + p) i) := rfl

/-- The cast of the successor is the successor of the cast. See `Fin.succ_cast_eq` for rewriting in
the reverse direction. -/
@[simp] theorem cast_succ_eq {n' : Nat} (i : Fin n) (h : n.succ = n'.succ) :
    cast h i.succ = (cast (Nat.succ.inj h) i).succ := rfl

theorem succ_cast_eq {n' : Nat} (i : Fin n) (h : n = n') :
    (cast h i).succ = cast (by rw [h]) i.succ := rfl

@[simp] theorem coe_castSucc (i : Fin n) : (Fin.castSucc i : Nat) = i := rfl

@[simp] theorem castSucc_mk (n i : Nat) (h : i < n) : castSucc ⟨i, h⟩ = ⟨i, Nat.lt.step h⟩ := rfl

@[simp] theorem cast_castSucc {n' : Nat} {h : n + 1 = n' + 1} {i : Fin n} :
    cast h (castSucc i) = castSucc (cast (Nat.succ.inj h) i) := rfl

theorem castSucc_lt_succ (i : Fin n) : Fin.castSucc i < i.succ :=
  lt_def.2 <| by simp only [coe_castSucc, val_succ, Nat.lt_succ_self]

theorem le_castSucc_iff {i : Fin (n + 1)} {j : Fin n} : i ≤ Fin.castSucc j ↔ i < j.succ := by
  simpa [lt_def, le_def] using Nat.succ_le_succ_iff.symm

theorem castSucc_lt_iff_succ_le {n : Nat} {i : Fin n} {j : Fin (n + 1)} :
    Fin.castSucc i < j ↔ i.succ ≤ j := .rfl

@[simp] theorem succ_last (n : Nat) : (last n).succ = last n.succ := rfl

@[simp] theorem succ_eq_last_succ {n : Nat} (i : Fin n.succ) :
    i.succ = last (n + 1) ↔ i = last n := by rw [← succ_last, succ_inj]

@[simp] theorem castSucc_castLT (i : Fin (n + 1)) (h : (i : Nat) < n) :
    castSucc (castLT i h) = i := rfl

@[simp] theorem castLT_castSucc {n : Nat} (a : Fin n) (h : (a : Nat) < n) :
    castLT (castSucc a) h = a := rfl

@[simp] theorem castSucc_lt_castSucc_iff {a b : Fin n} :
    Fin.castSucc a < Fin.castSucc b ↔ a < b := .rfl

theorem castSucc_inj {a b : Fin n} : castSucc a = castSucc b ↔ a = b := by simp [ext_iff]

theorem castSucc_lt_last (a : Fin n) : castSucc a < last n := a.is_lt

@[simp] theorem castSucc_zero : castSucc (0 : Fin (n + 1)) = 0 := rfl

@[simp] theorem castSucc_one {n : Nat} : castSucc (1 : Fin (n + 2)) = 1 := rfl

/-- `castSucc i` is positive when `i` is positive -/
theorem castSucc_pos {i : Fin (n + 1)} (h : 0 < i) : 0 < castSucc i := by
  simpa [lt_def] using h

@[simp] theorem castSucc_eq_zero_iff (a : Fin (n + 1)) : castSucc a = 0 ↔ a = 0 := by simp [ext_iff]

theorem castSucc_ne_zero_iff (a : Fin (n + 1)) : castSucc a ≠ 0 ↔ a ≠ 0 :=
  not_congr <| castSucc_eq_zero_iff a

theorem castSucc_fin_succ (n : Nat) (j : Fin n) :
    castSucc (Fin.succ j) = Fin.succ (castSucc j) := by simp [Fin.ext_iff]

@[simp]
theorem coeSucc_eq_succ {a : Fin n} : castSucc a + 1 = a.succ := by
  cases n
  · exact a.elim0
  · simp [ext_iff, add_def, Nat.mod_eq_of_lt (Nat.succ_lt_succ a.is_lt)]

theorem lt_succ {a : Fin n} : castSucc a < a.succ := by
  rw [castSucc, lt_def, coe_castAdd, val_succ]; exact Nat.lt_succ_self a.val

theorem exists_castSucc_eq {n : Nat} {i : Fin (n + 1)} : (∃ j, castSucc j = i) ↔ i ≠ last n :=
  ⟨fun ⟨j, hj⟩ => hj ▸ Fin.ne_of_lt j.castSucc_lt_last,
   fun hi => ⟨i.castLT <| Fin.val_lt_last hi, rfl⟩⟩

theorem succ_castSucc {n : Nat} (i : Fin n) : i.castSucc.succ = castSucc i.succ := rfl

@[simp] theorem coe_addNat (m : Nat) (i : Fin n) : (addNat i m : Nat) = i + m := rfl

@[simp] theorem addNat_one {i : Fin n} : addNat i 1 = i.succ := rfl

theorem le_coe_addNat (m : Nat) (i : Fin n) : m ≤ addNat i m :=
  Nat.le_add_left _ _

@[simp] theorem addNat_mk (n i : Nat) (hi : i < m) :
    addNat ⟨i, hi⟩ n = ⟨i + n, Nat.add_lt_add_right hi n⟩ := rfl

@[simp] theorem cast_addNat_zero {n n' : Nat} (i : Fin n) (h : n + 0 = n') :
    cast h (addNat i 0) = cast ((Nat.add_zero _).symm.trans h) i := rfl

/-- For rewriting in the reverse direction, see `Fin.cast_addNat_left`. -/
theorem addNat_cast {n n' m : Nat} (i : Fin n') (h : n' = n) :
    addNat (cast h i) m = cast (congrArg (. + m) h) (addNat i m) := rfl

theorem cast_addNat_left {n n' m : Nat} (i : Fin n') (h : n' + m = n + m) :
    cast h (addNat i m) = addNat (cast (Nat.add_right_cancel h) i) m := rfl

@[simp] theorem cast_addNat_right {n m m' : Nat} (i : Fin n) (h : n + m' = n + m) :
    cast h (addNat i m') = addNat i m :=
  ext <| (congrArg ((· + ·) (i : Nat)) (Nat.add_left_cancel h) : _)

@[simp] theorem coe_natAdd (n : Nat) {m : Nat} (i : Fin m) : (natAdd n i : Nat) = n + i := rfl

@[simp] theorem natAdd_mk (n i : Nat) (hi : i < m) :
    natAdd n ⟨i, hi⟩ = ⟨n + i, Nat.add_lt_add_left hi n⟩ := rfl

theorem le_coe_natAdd (m : Nat) (i : Fin n) : m ≤ natAdd m i := Nat.le_add_right ..

theorem natAdd_zero {n : Nat} : natAdd 0 = cast (Nat.zero_add n).symm := by ext; simp

/-- For rewriting in the reverse direction, see `Fin.cast_natAdd_right`. -/
theorem natAdd_cast {n n' : Nat} (m : Nat) (i : Fin n') (h : n' = n) :
    natAdd m (cast h i) = cast (congrArg _ h) (natAdd m i) := rfl

theorem cast_natAdd_right {n n' m : Nat} (i : Fin n') (h : m + n' = m + n) :
    cast h (natAdd m i) = natAdd m (cast (Nat.add_left_cancel h) i) := rfl

@[simp] theorem cast_natAdd_left {n m m' : Nat} (i : Fin n) (h : m' + n = m + n) :
    cast h (natAdd m' i) = natAdd m i :=
  ext <| (congrArg (· + (i : Nat)) (Nat.add_right_cancel h) : _)

theorem castAdd_natAdd (p m : Nat) {n : Nat} (i : Fin n) :
    castAdd p (natAdd m i) = cast (Nat.add_assoc ..).symm (natAdd m (castAdd p i)) := rfl

theorem natAdd_castAdd (p m : Nat) {n : Nat} (i : Fin n) :
    natAdd m (castAdd p i) = cast (Nat.add_assoc ..) (castAdd p (natAdd m i)) := rfl

theorem natAdd_natAdd (m n : Nat) {p : Nat} (i : Fin p) :
    natAdd m (natAdd n i) = cast (Nat.add_assoc ..) (natAdd (m + n) i) :=
  ext <| (Nat.add_assoc ..).symm

@[simp]
theorem cast_natAdd_zero {n n' : Nat} (i : Fin n) (h : 0 + n = n') :
    cast h (natAdd 0 i) = cast ((Nat.zero_add _).symm.trans h) i :=
  ext <| Nat.zero_add _

@[simp]
theorem cast_natAdd (n : Nat) {m : Nat} (i : Fin m) :
    cast (Nat.add_comm ..) (natAdd n i) = addNat i n := ext <| Nat.add_comm ..

@[simp]
theorem cast_addNat {n : Nat} (m : Nat) (i : Fin n) :
    cast (Nat.add_comm ..) (addNat i m) = natAdd m i := ext <| Nat.add_comm ..

@[simp] theorem natAdd_last {m n : Nat} : natAdd n (last m) = last (n + m) := rfl

theorem natAdd_castSucc {m n : Nat} {i : Fin m} : natAdd n (castSucc i) = castSucc (natAdd n i) :=
  rfl

/-! ### pred -/

@[simp] theorem coe_pred (j : Fin (n + 1)) (h : j ≠ 0) : (j.pred h : Nat) = j - 1 := rfl

@[simp] theorem succ_pred : ∀ (i : Fin (n + 1)) (h : i ≠ 0), (i.pred h).succ = i
  | ⟨0, h⟩, hi => by simp only [mk_zero, ne_eq, not_true] at hi
  | ⟨n + 1, h⟩, hi => rfl

@[simp]
theorem pred_succ (i : Fin n) {h : i.succ ≠ 0} : i.succ.pred h = i := by
  cases i
  rfl

theorem pred_eq_iff_eq_succ {n : Nat} (i : Fin (n + 1)) (hi : i ≠ 0) (j : Fin n) :
    i.pred hi = j ↔ i = j.succ :=
  ⟨fun h => by simp only [← h, Fin.succ_pred], fun h => by simp only [h, Fin.pred_succ]⟩

theorem pred_mk_succ (i : Nat) (h : i < n + 1) :
    Fin.pred ⟨i + 1, Nat.add_lt_add_right h 1⟩ (ne_of_val_ne (Nat.ne_of_gt (mk_succ_pos i h))) =
      ⟨i, h⟩ := by
  simp only [ext_iff, coe_pred, Nat.add_sub_cancel]

@[simp] theorem pred_mk_succ' (i : Nat) (h₁ : i + 1 < n + 1 + 1) (h₂) :
    Fin.pred ⟨i + 1, h₁⟩ h₂ = ⟨i, Nat.lt_of_succ_lt_succ h₁⟩ := pred_mk_succ i _

-- This is not a simp theorem by default, because `pred_mk_succ` is nicer when it applies.
theorem pred_mk {n : Nat} (i : Nat) (h : i < n + 1) (w) : Fin.pred ⟨i, h⟩ w =
    ⟨i - 1, Nat.sub_lt_right_of_lt_add (Nat.pos_iff_ne_zero.2 (Fin.val_ne_of_ne w)) h⟩ :=
  rfl

@[simp] theorem pred_le_pred_iff {n : Nat} {a b : Fin n.succ} {ha : a ≠ 0} {hb : b ≠ 0} :
    a.pred ha ≤ b.pred hb ↔ a ≤ b := by rw [← succ_le_succ_iff, succ_pred, succ_pred]

@[simp] theorem pred_lt_pred_iff {n : Nat} {a b : Fin n.succ} {ha : a ≠ 0} {hb : b ≠ 0} :
    a.pred ha < b.pred hb ↔ a < b := by rw [← succ_lt_succ_iff, succ_pred, succ_pred]

@[simp] theorem pred_inj :
    ∀ {a b : Fin (n + 1)} {ha : a ≠ 0} {hb : b ≠ 0}, a.pred ha = b.pred hb ↔ a = b
  | ⟨0, _⟩, _, ha, _ => by simp only [mk_zero, ne_eq, not_true] at ha
  | ⟨i + 1, _⟩, ⟨0, _⟩, _, hb => by simp only [mk_zero, ne_eq, not_true] at hb
  | ⟨i + 1, hi⟩, ⟨j + 1, hj⟩, ha, hb => by simp [ext_iff]

@[simp] theorem pred_one {n : Nat} :
    Fin.pred (1 : Fin (n + 2)) (Ne.symm (Fin.ne_of_lt one_pos)) = 0 := rfl

theorem pred_add_one (i : Fin (n + 2)) (h : (i : Nat) < n + 1) :
    pred (i + 1) (Fin.ne_of_gt (add_one_pos _ (lt_def.2 h))) = castLT i h := by
  rw [ext_iff, coe_pred, coe_castLT, val_add, val_one, Nat.mod_eq_of_lt, Nat.add_sub_cancel]
  exact Nat.add_lt_add_right h 1

@[simp] theorem coe_subNat (i : Fin (n + m)) (h : m ≤ i) : (i.subNat m h : Nat) = i - m := rfl

@[simp] theorem subNat_mk {i : Nat} (h₁ : i < n + m) (h₂ : m ≤ i) :
    subNat m ⟨i, h₁⟩ h₂ = ⟨i - m, Nat.sub_lt_right_of_lt_add h₂ h₁⟩ := rfl

@[simp] theorem pred_castSucc_succ (i : Fin n) :
    pred (castSucc i.succ) (Fin.ne_of_gt (castSucc_pos i.succ_pos)) = castSucc i := rfl

@[simp] theorem addNat_subNat {i : Fin (n + m)} (h : m ≤ i) : addNat (subNat m i h) m = i :=
  ext <| Nat.sub_add_cancel h

@[simp] theorem subNat_addNat (i : Fin n) (m : Nat) (h : m ≤ addNat i m := le_coe_addNat m i) :
    subNat m (addNat i m) h = i := ext <| Nat.add_sub_cancel i m

@[simp] theorem natAdd_subNat_cast {i : Fin (n + m)} (h : n ≤ i) :
    natAdd n (subNat n (cast (Nat.add_comm ..) i) h) = i := by simp [← cast_addNat]; rfl

/-! ### recursion and induction principles -/

/-- Define `motive n i` by induction on `i : Fin n` interpreted as `(0 : Fin (n - i)).succ.succ…`.
This function has two arguments: `zero n` defines `0`-th element `motive (n+1) 0` of an
`(n+1)`-tuple, and `succ n i` defines `(i+1)`-st element of `(n+1)`-tuple based on `n`, `i`, and
`i`-th element of `n`-tuple. -/
-- FIXME: Performance review
@[elab_as_elim] def succRec {motive : ∀ n, Fin n → Sort _}
    (zero : ∀ n, motive n.succ (0 : Fin (n + 1)))
    (succ : ∀ n i, motive n i → motive n.succ i.succ) : ∀ {n : Nat} (i : Fin n), motive n i
  | 0, i => i.elim0
  | Nat.succ n, ⟨0, _⟩ => by rw [mk_zero]; exact zero n
  | Nat.succ _, ⟨Nat.succ i, h⟩ => succ _ _ (succRec zero succ ⟨i, Nat.lt_of_succ_lt_succ h⟩)

/-- Define `motive n i` by induction on `i : Fin n` interpreted as `(0 : Fin (n - i)).succ.succ…`.
This function has two arguments: `zero n` defines `0`-th element `motive (n+1) 0` of an `(n+1)`-tuple,
and `succ n i` defines `(i+1)`-st element of `(n+1)`-tuple based on `n`, `i`, and `i`-th element
of `n`-tuple.

A version of `Fin.succRec` taking `i : Fin n` as the first argument. -/
-- FIXME: Performance review
@[elab_as_elim] def succRecOn {n : Nat} (i : Fin n) {motive : ∀ n, Fin n → Sort _}
    (zero : ∀ n, motive (n + 1) 0) (succ : ∀ n i, motive n i → motive (Nat.succ n) i.succ) :
    motive n i := i.succRec zero succ

@[simp] theorem succRecOn_zero {motive : ∀ n, Fin n → Sort _} {zero succ} (n) :
    @Fin.succRecOn (n + 1) 0 motive zero succ = zero n := by
  cases n <;> rfl

@[simp] theorem succRecOn_succ {motive : ∀ n, Fin n → Sort _} {zero succ} {n} (i : Fin n) :
    @Fin.succRecOn (n + 1) i.succ motive zero succ = succ n i (Fin.succRecOn i zero succ) := by
  cases i; rfl

/-- Define `motive i` by induction on `i : Fin (n + 1)` via induction on the underlying `Nat` value.
This function has two arguments: `zero` handles the base case on `motive 0`,
and `succ` defines the inductive step using `motive i.castSucc`.
-/
-- FIXME: Performance review
@[elab_as_elim] def induction {motive : Fin (n + 1) → Sort _} (zero : motive 0)
    (succ : ∀ i : Fin n, motive (castSucc i) → motive i.succ) :
    ∀ i : Fin (n + 1), motive i
  | ⟨0, hi⟩ => by rwa [Fin.mk_zero]
  | ⟨i+1, hi⟩ => succ ⟨i, Nat.lt_of_succ_lt_succ hi⟩ (induction zero succ ⟨i, Nat.lt_of_succ_lt hi⟩)

@[simp] theorem induction_zero {motive : Fin (n + 1) → Sort _} (zero : motive 0)
    (hs : ∀ i : Fin n, motive (castSucc i) → motive i.succ) :
    (induction zero hs : ∀ i : Fin (n + 1), motive i) 0 = zero := rfl

@[simp] theorem induction_succ {motive : Fin (n + 1) → Sort _} (zero : motive 0)
    (succ : ∀ i : Fin n, motive (castSucc i) → motive i.succ) (i : Fin n) :
    induction (motive := motive) zero succ i.succ = succ i (induction zero succ (castSucc i)) := rfl

/-- Define `motive i` by induction on `i : Fin (n + 1)` via induction on the underlying `Nat` value.
This function has two arguments: `zero` handles the base case on `motive 0`,
and `succ` defines the inductive step using `motive i.castSucc`.

A version of `Fin.induction` taking `i : Fin (n + 1)` as the first argument.
-/
-- FIXME: Performance review
@[elab_as_elim] def inductionOn (i : Fin (n + 1)) {motive : Fin (n + 1) → Sort _} (zero : motive 0)
    (succ : ∀ i : Fin n, motive (castSucc i) → motive i.succ) : motive i := induction zero succ i

/-- Define `f : Π i : Fin n.succ, motive i` by separately handling the cases `i = 0` and
`i = j.succ`, `j : Fin n`. -/
@[elab_as_elim] def cases {motive : Fin (n + 1) → Sort _}
    (zero : motive 0) (succ : ∀ i : Fin n, motive i.succ) :
    ∀ i : Fin (n + 1), motive i := induction zero fun i _ => succ i

@[simp] theorem cases_zero {n} {motive : Fin (n + 1) → Sort _} {zero succ} :
    @Fin.cases n motive zero succ 0 = zero := rfl

@[simp] theorem cases_succ {n} {motive : Fin (n + 1) → Sort _} {zero succ} (i : Fin n) :
    @Fin.cases n motive zero succ i.succ = succ i := rfl

@[simp] theorem cases_succ' {n} {motive : Fin (n + 1) → Sort _} {zero succ}
    {i : Nat} (h : i + 1 < n + 1) :
    @Fin.cases n motive zero succ ⟨i.succ, h⟩ = succ ⟨i, Nat.lt_of_succ_lt_succ h⟩ := rfl

theorem forall_fin_succ {P : Fin (n + 1) → Prop} : (∀ i, P i) ↔ P 0 ∧ ∀ i : Fin n, P i.succ :=
  ⟨fun H => ⟨H 0, fun _ => H _⟩, fun ⟨H0, H1⟩ i => Fin.cases H0 H1 i⟩

theorem exists_fin_succ {P : Fin (n + 1) → Prop} : (∃ i, P i) ↔ P 0 ∨ ∃ i : Fin n, P i.succ :=
  ⟨fun ⟨i, h⟩ => Fin.cases Or.inl (fun i hi => Or.inr ⟨i, hi⟩) i h, fun h =>
    (h.elim fun h => ⟨0, h⟩) fun ⟨i, hi⟩ => ⟨i.succ, hi⟩⟩

theorem forall_fin_one {p : Fin 1 → Prop} : (∀ i, p i) ↔ p 0 :=
  ⟨fun h => h _, fun h i => Subsingleton.elim i 0 ▸ h⟩

theorem exists_fin_one {p : Fin 1 → Prop} : (∃ i, p i) ↔ p 0 :=
  ⟨fun ⟨i, h⟩ => Subsingleton.elim i 0 ▸ h, fun h => ⟨_, h⟩⟩

theorem forall_fin_two {p : Fin 2 → Prop} : (∀ i, p i) ↔ p 0 ∧ p 1 :=
  forall_fin_succ.trans <| and_congr_right fun _ => forall_fin_one

theorem exists_fin_two {p : Fin 2 → Prop} : (∃ i, p i) ↔ p 0 ∨ p 1 :=
  exists_fin_succ.trans <| or_congr_right exists_fin_one

theorem fin_two_eq_of_eq_zero_iff : ∀ {a b : Fin 2}, (a = 0 ↔ b = 0) → a = b := by
  simp [forall_fin_two]

/--
Define `motive i` by reverse induction on `i : Fin (n + 1)` via induction on the underlying `Nat`
value. This function has two arguments: `last` handles the base case on `motive (Fin.last n)`,
and `cast` defines the inductive step using `motive i.succ`, inducting downwards.
-/
@[elab_as_elim] def reverseInduction {motive : Fin (n + 1) → Sort _} (last : motive (Fin.last n))
    (cast : ∀ i : Fin n, motive i.succ → motive (castSucc i)) (i : Fin (n + 1)) : motive i :=
  if hi : i = Fin.last n then _root_.cast (congrArg motive hi.symm) last
  else
    let j : Fin n := ⟨i, Nat.lt_of_le_of_ne (Nat.le_of_lt_succ i.2) fun h => hi (Fin.ext h)⟩
    cast _ (reverseInduction last cast j.succ)
termination_by _ => n + 1 - i
decreasing_by decreasing_with
  -- FIXME: we put the proof down here to avoid getting a dummy `have` in the definition
  exact Nat.add_sub_add_right .. ▸ Nat.sub_lt_sub_left i.2 (Nat.lt_succ_self i)

@[simp] theorem reverseInduction_last {n : Nat} {motive : Fin (n + 1) → Sort _} {zero succ} :
    (reverseInduction zero succ (Fin.last n) : motive (Fin.last n)) = zero := by
  rw [reverseInduction]; simp; rfl

@[simp] theorem reverseInduction_castSucc {n : Nat} {motive : Fin (n + 1) → Sort _} {zero succ}
    (i : Fin n) : reverseInduction (motive := motive) zero succ (castSucc i) =
      succ i (reverseInduction zero succ i.succ) := by
  rw [reverseInduction, dif_neg (Fin.ne_of_lt (Fin.castSucc_lt_last i))]; rfl

/-- Define `f : Π i : Fin n.succ, motive i` by separately handling the cases `i = Fin.last n` and
`i = j.castSucc`, `j : Fin n`. -/
@[elab_as_elim] def lastCases {n : Nat} {motive : Fin (n + 1) → Sort _} (last : motive (Fin.last n))
    (cast : ∀ i : Fin n, motive (castSucc i)) (i : Fin (n + 1)) : motive i :=
  reverseInduction last (fun i _ => cast i) i

@[simp] theorem lastCases_last {n : Nat} {motive : Fin (n + 1) → Sort _} {last cast} :
    (Fin.lastCases last cast (Fin.last n) : motive (Fin.last n)) = last :=
  reverseInduction_last ..

@[simp] theorem lastCases_castSucc {n : Nat} {motive : Fin (n + 1) → Sort _} {last cast}
    (i : Fin n) : (Fin.lastCases last cast (Fin.castSucc i) : motive (Fin.castSucc i)) = cast i :=
  reverseInduction_castSucc ..

/-- Define `f : Π i : Fin (m + n), motive i` by separately handling the cases `i = castAdd n i`,
`j : Fin m` and `i = natAdd m j`, `j : Fin n`. -/
@[elab_as_elim] def addCases {m n : Nat} {motive : Fin (m + n) → Sort u}
    (left : ∀ i, motive (castAdd n i)) (right : ∀ i, motive (natAdd m i))
    (i : Fin (m + n)) : motive i :=
  if hi : (i : Nat) < m then (castAdd_castLT n i hi) ▸ (left (castLT i hi))
  else (natAdd_subNat_cast (Nat.le_of_not_lt hi)) ▸ (right _)

@[simp] theorem addCases_left {m n : Nat} {motive : Fin (m + n) → Sort _} {left right} (i : Fin m) :
    addCases (motive := motive) left right (Fin.castAdd n i) = left i := by
  rw [addCases, dif_pos (castAdd_lt _ _)]; rfl

@[simp]
theorem addCases_right {m n : Nat} {motive : Fin (m + n) → Sort _} {left right} (i : Fin n) :
    addCases (motive := motive) left right (natAdd m i) = right i := by
  have : ¬(natAdd m i : Nat) < m := Nat.not_lt.2 (le_coe_natAdd ..)
  rw [addCases, dif_neg this]; exact eq_of_heq <| (eqRec_heq _ _).trans (by congr 1; simp)

/-! ### clamp -/

@[simp] theorem coe_clamp (n m : Nat) : (clamp n m : Nat) = min n m := rfl

/-! ### mul -/

theorem val_mul {n : Nat} : ∀ a b : Fin n, (a * b).val = a.val * b.val % n
  | ⟨_, _⟩, ⟨_, _⟩ => rfl

theorem coe_mul {n : Nat} : ∀ a b : Fin n, ((a * b : Fin n) : Nat) = a * b % n
  | ⟨_, _⟩, ⟨_, _⟩ => rfl

protected theorem mul_one (k : Fin (n + 1)) : k * 1 = k := by
  match n with
  | 0 => exact Subsingleton.elim (α := Fin 1) ..
  | n+1 => simp [ext_iff, mul_def, Nat.mod_eq_of_lt (is_lt k)]

protected theorem mul_comm (a b : Fin n) : a * b = b * a :=
  ext <| by rw [mul_def, mul_def, Nat.mul_comm]

protected theorem one_mul (k : Fin (n + 1)) : (1 : Fin (n + 1)) * k = k := by
  rw [Fin.mul_comm, Fin.mul_one]

protected theorem mul_zero (k : Fin (n + 1)) : k * 0 = 0 := by simp [ext_iff, mul_def]

protected theorem zero_mul (k : Fin (n + 1)) : (0 : Fin (n + 1)) * k = 0 := by
  simp [ext_iff, mul_def]

end Fin

namespace USize

@[simp] theorem lt_def {a b : USize} : a < b ↔ a.toNat < b.toNat := .rfl

@[simp] theorem le_def {a b : USize} : a ≤ b ↔ a.toNat ≤ b.toNat := .rfl

@[simp] theorem zero_toNat : (0 : USize).toNat = 0 := Nat.zero_mod _

@[simp] theorem mod_toNat (a b : USize) : (a % b).toNat = a.toNat % b.toNat :=
  Fin.mod_val ..

@[simp] theorem div_toNat (a b : USize) : (a / b).toNat = a.toNat / b.toNat :=
  Fin.div_val ..

@[simp] theorem modn_toNat (a : USize) (b : Nat) : (a.modn b).toNat = a.toNat % b :=
  Fin.modn_val ..

theorem mod_lt (a b : USize) (h : 0 < b) : a % b < b := USize.modn_lt _ (by simp at h; exact h)

theorem toNat.inj : ∀ {a b : USize}, a.toNat = b.toNat → a = b
  | ⟨_, _⟩, ⟨_, _⟩, rfl => rfl

end USize
