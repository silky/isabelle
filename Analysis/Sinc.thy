(*
Theory: Some_Calculus.thy
Authors: Jeremy Avigad, Luke Serafin

Some routine calculations from undergraduate calculus.
*)

theory Sinc

imports Interval_Integral

begin

(** Derivatives and integrals for CLT. **)

lemma integral_expneg_alpha_atLeast0:
  fixes u :: real
  assumes pos: "0 < u"
  shows "LBINT x=0..\<infinity>. exp (-x * u) = 1/u"
apply (subst interval_integral_FTC_nonneg[of _ _ "\<lambda>x. -(1/u) * exp (-x * u)" _ "-(1/u)" 0])
using pos apply (auto intro!: DERIV_intros)
apply (subgoal_tac "(((\<lambda>x. - (exp (- (x * u)) / u)) \<circ> real) ---> - (1 / u)) (at 0)")
apply (subst (asm) filterlim_at_split, force)
apply (subst zero_ereal_def)
apply (subst filterlim_at_split)
apply (simp_all add: ereal_tendsto_simps)
apply (subst filterlim_at_split[symmetric])
apply (auto intro!: tendsto_intros)
apply (subst exp_zero[symmetric])
apply (rule tendsto_compose[of exp])
using isCont_exp unfolding isCont_def apply metis
apply (subst tendsto_minus_cancel_left[symmetric], simp)
apply (rule tendsto_mult_left_zero, rule tendsto_ident_at)
apply (subst divide_inverse, subst minus_mult_left)
apply (rule tendsto_mult_left_zero)
apply (subst tendsto_minus_cancel_left[symmetric], simp)
apply (rule filterlim_compose[of exp _ at_bot])
apply (rule exp_at_bot)
apply (subst filterlim_uminus_at_top [symmetric])
apply (subst mult_commute)
apply (rule filterlim_tendsto_pos_mult_at_top [OF _ pos])
apply auto
by (rule filterlim_ident)

lemma Collect_eq_Icc: "{r. t \<le> r \<and> r \<le> b} = {t .. b}"
  by auto

(* From Billingsley section 18. *)
lemma ex_18_4_1:
  assumes "t \<ge> 0"
  shows "LBINT x=0..t. exp (-u * x) * sin x = (1/(1+u^2)) *
  (1 - exp (-u * t) * (u * sin t + cos t))"

  apply (subst zero_ereal_def)
  apply (subst interval_integral_FTC_finite 
      [where F = "(\<lambda>x. (1/(1+u^2)) * (1 - exp (-u * x) * (u * sin x + cos x)))"])
  apply (auto intro: continuous_at_imp_continuous_on)
  apply (rule DERIV_imp_DERIV_within, auto)
  apply (auto intro!: DERIV_intros)
by (simp_all add: power2_eq_square field_simps)

lemma ex_18_4_2_deriv:
  "DERIV (\<lambda>u. 1/x * (1 - exp (-u * x)) * \<bar>sin x\<bar>) u :> \<bar>exp (-u * x) * sin x\<bar>"
  apply (auto simp only: intro!: DERIV_intros)
  by (simp add: abs_mult)

(*** not needed ***)
lemma ex_18_4_2_bdd_integral:
  assumes "s \<ge> 0"
  shows "LBINT u=0..s. \<bar>exp (-u * x) * sin x\<bar> =
  1/x * (1 - exp (-s * x)) * \<bar>sin x\<bar>"

  apply (subst zero_ereal_def)
  apply (subst interval_integral_FTC_finite 
      [where F = "\<lambda>u. 1/x * (1 - exp (-u * x)) * \<bar>sin x\<bar>"])
  apply (auto intro: continuous_at_imp_continuous_on) [1]
  apply (rule DERIV_imp_DERIV_within, force)
  (* curiously, just copying the proof of ex_18_4_2_deriv doesn't work *)
  apply (rule ex_18_4_2_deriv)
  apply auto
done

(* clean this up! it should be shorter *)
lemma ex_18_4_2_ubdd_integral:
  fixes x
  assumes pos: "0 < x"
  shows "LBINT u=0..\<infinity>. \<bar>exp (-u * x) * sin x\<bar> = \<bar>sin x\<bar> / x" 

  apply (subst interval_integral_FTC_nonneg [where F = "\<lambda>u. 1/x * (1 - exp (-u * x)) * \<bar>sin x\<bar>"
    and A = 0 and B = "abs (sin x) / x"])
  apply force
  apply (rule ex_18_4_2_deriv)
  apply auto
  (* this is a little annoying -- having to replace 0 by "ereal 0" *)
  apply (subst zero_ereal_def)+
  apply (simp_all add: ereal_tendsto_simps)
  (* What follows are two simple limit calculations. Clean these up -- they should be
  shorter. *)
  apply (rule filterlim_mono [of _ "nhds 0" "at 0"], auto)
  prefer 2
  apply (rule at_le, simp)
  apply (subst divide_real_def)
  apply (rule tendsto_mult_left_zero)+
  apply (subgoal_tac "0 = 1 - 1")
  apply (erule ssubst)
  apply (rule tendsto_diff, auto)
  apply (subgoal_tac "1 = exp 0")
  apply (erule ssubst)
  apply (rule tendsto_compose) back
  apply (subst isCont_def [symmetric], auto)
  apply (rule tendsto_minus_cancel, auto)
  apply (rule tendsto_mult_left_zero, rule tendsto_ident_at)
  (* this is the second *)
  apply (subst divide_real_def)+
  apply (subgoal_tac "abs (sin x) * inverse x = 1 * abs (sin x) * inverse x")
  apply (erule ssubst)
  apply (rule tendsto_mult)+
  apply auto
  apply (subgoal_tac "1 = 1 - 0")
  apply (erule ssubst) back
  apply (rule tendsto_diff, auto)
  apply (rule filterlim_compose) back
  apply (rule exp_at_bot)
  apply (subst filterlim_uminus_at_top [symmetric])
  apply (subst mult_commute)
  apply (rule filterlim_tendsto_pos_mult_at_top [OF _ pos])
  apply auto
by (rule filterlim_ident)

lemma Billingsley_ex_17_5: "LBINT x=-\<infinity>..\<infinity>. inverse (1 + x^2) = pi"
  apply (subst interval_integral_substitution_nonneg[of "-pi/2" "pi/2" tan "\<lambda>x. 1 + (tan x)^2"])
  apply (auto intro: DERIV_intros)
  apply (subst tan_sec)
  using pi_half cos_is_zero
  apply (metis cos_gt_zero_pi less_divide_eq_numeral1(1) less_numeral_extra(3))
  using DERIV_tan
  apply (metis cos_gt_zero_pi less_divide_eq_numeral1(1) power2_less_0 power_inverse power_zero_numeral)
  apply (rule isCont_add, force)
  apply (subst power2_eq_square)
  apply (subst isCont_mult)
  apply (rule isCont_tan)
  (* Following line duplicated from above. *)
  using pi_half cos_is_zero
  apply (metis cos_gt_zero_pi less_divide_eq_numeral1(1) less_numeral_extra(3))
  apply (simp_all add: ereal_tendsto_simps filterlim_tan_at_left)
  apply (subst minus_divide_left)+
  by (rule filterlim_tan_at_right)

definition sinc :: "real \<Rightarrow> real" where "sinc t \<equiv> LBINT x=0..t. sin x / x"

(* Put in Interval_Integral. *)
lemma interval_integral_endpoint_split:
  fixes a b c :: ereal
  fixes f :: "real \<Rightarrow> real"
  assumes "interval_lebesgue_integrable lborel a b f" "a \<le> c" "c \<le> b"
  shows "LBINT x=a..b. f x = (LBINT x=a..c. f x) + (LBINT x=c..b. f x)"
unfolding interval_lebesgue_integral_def einterval_def apply (auto intro: assms)
apply (subgoal_tac "{x. a < ereal x \<and> ereal x < b} = {x. a < ereal x \<and> x < c} \<union>
                    {x. a < ereal x \<and> ereal x = c \<and> ereal x < b} \<union> {x. c < x \<and> ereal x < b}")
apply (auto intro: order_less_imp_le)
apply (subst set_integral_Un, auto)
apply (rule set_integrable_subset[where A = "{x. a < ereal x \<and> ereal x < b}"])
using assms(1) unfolding interval_lebesgue_integrable_def einterval_def apply auto
apply (rule set_integrable_subset[where A = "{x. a < ereal x \<and> ereal x < b}"])
using assms(1) unfolding interval_lebesgue_integrable_def einterval_def apply auto
apply (subst set_integral_Un, auto)
apply (subst set_integrable_subset[where A = "{x. a < ereal x \<and> ereal x < b}"])
using assms(1) unfolding interval_lebesgue_integrable_def einterval_def apply auto
apply (subst set_integrable_subset[where A = "{x. a < ereal x \<and> ereal x < b}"])
using assms(1) unfolding interval_lebesgue_integrable_def einterval_def apply auto
apply (cases c rule: ereal_cases, auto)
proof -
  fix r
  show "set_lebesgue_integral lborel {x. x = r \<and> a < ereal x \<and> ereal x < b} f = 0"
    apply (subgoal_tac "0 = (LBINT x. 0)")
    apply (erule ssubst)
    apply (rule integral_cong_AE)
    by (rule AE_I[where N = "{r}"], auto simp add: indicator_def)
qed

(** Add to main Lebesgue integration library; does not require integrability as hypothesis, which in
my experience greatly increases usability. **)
lemma positive_integral_eq_integral_measurable:
  assumes f: "f \<in> borel_measurable M" and I: "integral\<^sup>L M f \<noteq> 0"
  assumes nonneg: "AE x in M. 0 \<le> f x" 
  shows "(\<integral>\<^sup>+ x. ereal (f x) \<partial>M) = ereal (integral\<^sup>L M f)"
proof -
  have "(\<integral>\<^sup>+ x. ereal (- f x) \<partial>M) = (\<integral>\<^sup>+ x. max 0 (ereal (- f x)) \<partial>M)"
    using positive_integral_max_0 by metis
  also have "... = (\<integral>\<^sup>+ x. 0 \<partial>M)"
    using nonneg by (intro positive_integral_cong_AE) (auto split: split_max)
  also have "... = 0" by (subst zero_ereal_def) (subst positive_integral_eq_integral, auto)
  finally have "real (\<integral>\<^sup>+ x. ereal (f x) \<partial>M) = integral\<^sup>L M f"
    using real_of_ereal_0 unfolding lebesgue_integral_def by auto
  thus ?thesis
    apply (subst (asm) ereal.inject[symmetric])
    apply (subst (asm) ereal_real)
    using I ereal_eq_0 by metis
qed

thm pair_sigma_finite.Fubini_integral

(* Perhaps omit pair_sigma_finite? *)
lemma (in pair_sigma_finite) interval_Fubini_integral:
  fixes f :: "real \<times> real \<Rightarrow> real"
  fixes a b c d :: ereal
  assumes "a < b" "c < d" "integrable (M1 \<Otimes>\<^sub>M M2) f"
  shows "LINT y=a..b|M1. (LINT x=c..d|M2. f (x, y)) = LINT x=c..d|M1. (LINT y=a..b|M2. f (x, y))"
using assms sorry
    
lemma sinc_at_top_lemma:
  fixes t :: real
  assumes "t \<ge> 0"
  shows "sinc t = pi / 2 - (LBINT u=0..\<infinity>. inverse (1 + u^2) * exp (-u * t) * (u * sin t + cos t))"
proof -
  have 179: "LBINT x=0..\<infinity>. inverse (1 + x^2) = pi / 2"
  proof -
    have "LBINT x=-\<infinity>..\<infinity>. inverse (1 + x^2) = (LBINT x=-\<infinity>..0. inverse (1 + x^2)) +
                                               (LBINT x=0..\<infinity>. inverse (1 + x^2))"
      apply (rule interval_integral_endpoint_split[of "-\<infinity>" "\<infinity>" "\<lambda>x. inverse (1 + x^2)" 0], auto)
      apply (unfold interval_lebesgue_integrable_def einterval_def integrable_def, auto)
      apply (subst power2_eq_square, auto)
      apply (subst (asm) positive_integral_eq_integral_measurable)
      apply (subst power2_eq_square, auto)
      using Billingsley_ex_17_5 unfolding interval_lebesgue_integral_def einterval_def apply auto
      apply (subst (asm) positive_integral_max_0[symmetric])
      apply (subst (asm) power2_eq_square)
    proof -
      have *: "\<And>x. max 0 (ereal (- inverse (1 + x * x))) = 0"
        by (metis comm_semiring_1_class.normalizing_semiring_rules(4) ereal_max_0
            inverse_minus_eq inverse_nonpositive_iff_nonpositive le_add_same_cancel1 max.boundedE
            max.order_iff neg_le_0_iff_le zero_ereal_def zero_le_double_add_iff_zero_le_single_add
            zero_le_square)
        assume "\<integral>\<^sup>+ x. max 0 (ereal (- inverse (1 + x * x))) \<partial>lborel = \<infinity>"
        thus False by (subst (asm) *) auto
    qed
    moreover have "(LBINT x=-\<infinity>..0. inverse (1 + x^2)) = (LBINT x=0..\<infinity>. inverse (1 + x^2))"
      unfolding interval_lebesgue_integral_def einterval_def apply auto
      apply (subst power2_eq_square)+
      apply (subst lebesgue_integral_real_affine[of "-1" "\<lambda>x. inverse (1 + x * x) * indicator {x. 0 < x} x" 0])
      by (auto simp add: indicator_def)
    ultimately show ?thesis using Billingsley_ex_17_5 by simp
  qed
  have "AE x \<in> {0..} in lborel. LBINT u=0..\<infinity>. exp (-u * x) = 1/x"
    apply (rule AE_I[where N = "{0}"], auto)
    apply (subst (asm) minus_mult_left)
    using integral_expneg_alpha_atLeast0 using less_eq_real_def by metis
  hence "sinc t = LBINT x=0..t. sin x * (LBINT u=0..\<infinity>. exp (-u * x))" sorry
  also have "... = LBINT x=0..t. (LBINT u=0..\<infinity>. sin x * exp (-u * x))"
    apply (subst interval_lebesgue_integral_cmult(2))
    unfolding interval_lebesgue_integrable_def einterval_def integrable_def apply auto
    using integral_expneg_alpha_atLeast0 positive_integral_eq_integral_measurable sorry
  also have "... = LBINT u=0..\<infinity>. (LBINT x=0..t. sin x * exp (-u * x))"
    using pair_sigma_finite.Fubini_integral (* Need an interval_integral version of this. *) sorry
  also have "... = (LBINT u=0..\<infinity>. inverse (1 + u^2)) - (LBINT u=0..\<infinity>. inverse (1 + u^2) *
    exp (-u * t) * (u * sin t + cos t))" sorry
  finally show "sinc t = pi / 2 - (LBINT u=0..\<infinity>. inverse (1 + u^2) * exp (-u * t) *
    (u * sin t + cos t))" using 179 by simp
qed

lemma sinc_at_top: "(sinc ---> pi / 2) at_top"
  sorry

lemma Billingsley_26_15:
  assumes "T \<ge> 0"
  shows "\<And>\<theta>. LBINT t=0..T. sin (t * \<theta>) / t = sgn \<theta> * sinc (T * \<bar>\<theta>\<bar>)"
  sorry

end