(* 
Normal_Moments
Author: Jeremy Avigad

The moments of the normal distribution.

TODO: Merge this file with Normal_Distribution.

*)

theory Normal_Moments

imports Normal_Distribution Interval_Integral

begin

(* extracted from Normal_Distribution *)
lemma integral_exp_neg_x_squared: 
  shows
    "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2))" and 
    "LBINT x:{0..}. exp (- x\<^sup>2) = sqrt pi / 2"
proof -
  have 1: "(\<integral>\<^sup>+xa. ereal (exp (- xa\<^sup>2)) * indicator {0..} xa \<partial>lborel) = ereal (sqrt pi) / ereal 2"
    apply (subst positive_integral_ereal_indicator_mult)
    apply (subst gaussian_integral_positive[symmetric])
    apply (subst(2) positive_integral_even_function) 
    apply (auto simp: field_simps)
    by (cases "\<integral>\<^sup>+x. ereal (indicator {0..} x * exp (- x\<^sup>2)) \<partial>lborel") auto
  (* TODO: refactor *)
  show "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2))"
    apply (rule integrable_if_positive_integral [of _ _ "sqrt pi / 2"])
    apply (subst positive_integral_ereal_indicator_mult[symmetric])
    apply (subst 1)
    by (auto split:split_indicator)
  show "LBINT x:{0..}. exp (- x\<^sup>2) = sqrt pi / 2"
    apply (rule lebesgue_integral_eq_positive_integral)
    apply (subst positive_integral_ereal_indicator_mult[symmetric])
    apply (subst 1)
    by (auto split:split_indicator)
qed

(* rewrite this *)
lemma integral_x_exp_neg_x_squared: 
  shows
    "set_integrable lborel {0..} (\<lambda>x. x * exp (- x\<^sup>2))" and 
    "LBINT x:{0..}. x * exp (- x\<^sup>2) = 1 / 2"
proof -
  have *: "\<integral>\<^sup>+ x. ereal (x * exp (- x\<^sup>2) * indicator {0..} x) \<partial>lborel =
      ereal (1 / 2)"
    apply (subst times_ereal.simps(1) [symmetric], subst ereal_indicator)
    by (rule positive_integral_x_exp_x_square_indicator [simplified])
  show "set_integrable lborel {0..} (\<lambda>x. x * exp (- x\<^sup>2))"
    apply (rule integrable_if_positive_integral, rule *)
    by (rule AE_I2, auto split: split_indicator intro!: mult_nonneg_nonneg)
  show "LBINT x:{0..}. x * exp (- x\<^sup>2) = 1 / 2"
    apply (rule lebesgue_integral_eq_positive_integral, rule *)
    by (rule AE_I2, auto split: split_indicator intro!: mult_nonneg_nonneg)
qed

lemma aux1:
  fixes b :: real and k :: nat
  assumes "0 \<le> b"
  shows "(LBINT x:{0..b}. exp (- x\<^sup>2) * x ^ (k + 2)) =
    (k + 1) / 2 * (LBINT x:{0..b}. exp (- x\<^sup>2) * x ^ k) - exp (- b\<^sup>2) * b ^ (k + 1) / 2"
proof -
  {
    fix a b :: real and k :: nat
    assume "a \<le> b"    let ?g = "\<lambda>x :: real. (k + 1) * x^k"
    let ?G = "\<lambda>x :: real. x^(k + 1)"
    let ?f = "\<lambda>x. - 2 * x * exp (- (x^2))"
    let ?F = "\<lambda>x. exp (- (x^2))"
    have "LBINT x:{a..b}. exp (- x\<^sup>2) * (real (k + 1) * x ^ k) =
        exp (- b\<^sup>2) * b ^ (k + 1) - exp (- a\<^sup>2) * a ^ (k + 1) -
        (LBINT x:{a..b}. - 2 * x * exp (- x\<^sup>2) * x ^ (k + 1))"
      apply (rule integral_by_parts [of a b ?f ?g ?F ?G])
      using `a \<le> b` apply (auto intro!: derivative_eq_intros)
      apply (case_tac "k = 0", auto)
      apply (subst mult_assoc)
      by (subst power_Suc2 [symmetric], simp add: real_of_nat_Suc field_simps
        real_of_nat_def)
  }
  note this [of 0 b k]
  also have "(LBINT x:{0..b}. exp (- x\<^sup>2) * (real (k + 1) * x ^ k)) = 
      real (k + 1) * (LBINT x:{0..b}. exp (- x\<^sup>2) * x ^ k)"
    apply (subst set_integral_cmult(2) [symmetric])
    apply (rule borel_integrable_atLeastAtMost')
    apply (rule continuous_at_imp_continuous_on)
    by (auto simp add: field_simps)
  also have "(LBINT x:{0..b}. - 2 * x * exp (- x\<^sup>2) * x ^ (k + 1)) =
       -2 * (LBINT x:{0..b}. exp (- x\<^sup>2) * x ^ (k + 2))"
    apply (subst set_integral_cmult(2) [symmetric])
    apply (rule borel_integrable_atLeastAtMost')
    apply (rule continuous_at_imp_continuous_on)
    by (auto simp add: field_simps)
  finally show ?thesis
    by (simp add: field_simps assms)
qed    

lemma aux2:
  fixes k :: nat
  assumes 
    "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * x ^ k)"
  shows
    "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * x ^ (k + 2))"
  and 
    "(LBINT x:{0..}. exp (- x\<^sup>2) * x ^ (k + 2)) = (k + 1) / 2 * (LBINT x:{0..}. exp (- x\<^sup>2) * x ^ k)"
proof -
  let ?f1 = "\<lambda>y::real. LBINT x:{0..y}. exp (- x\<^sup>2) * x ^ (k + 2)"
  let ?f2 = "\<lambda>y::real. LBINT x:{0..y}. exp (- x\<^sup>2) * x ^ k"
  let ?f2_lim = "LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ k)"
  let ?f3 = "\<lambda>y::real. exp (- y\<^sup>2) * y ^ (k + 1) / 2"
  let ?f4 = "\<lambda>y. (k + 1) / 2 * ?f2 y - ?f3 y" 
  have 1: "eventually (\<lambda>y. ?f1 y = ?f4 y) at_top"
    by (rule eventually_elim1 [OF eventually_ge_at_top [of 0]], rule aux1, auto)
  have 2: "(?f2 ---> ?f2_lim) at_top"
  proof -
    have a: "?f2 = (\<lambda>y. LBINT x:{..y}. exp(- x\<^sup>2) * (x ^ k) * indicator {0..} x)"
      by (rule ext, rule integral_cong, auto split: split_indicator)
    have b: "(\<dots> ---> (LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ k))) at_top"
      by (rule tendsto_integral_at_top, auto, rule assms)
    show ?thesis by (subst a, rule b)
  qed
  have 3: "(?f3 ---> 0) at_top"
  proof -
    let ?f5 = "\<lambda>k :: nat. \<lambda>y :: real. (y^2)^(k + 1) / exp (y\<^sup>2)"
    have *: "\<And>k. (?f5 k ---> 0) at_top"
      apply (rule filterlim_compose) back
      apply (rule tendsto_power_div_exp_0)
      by (rule filterlim_power2_at_top)
    let ?f6 = "(\<lambda>y :: real. exp (- y\<^sup>2) * y ^ (k + 1))"
    have **: "(?f6 ---> 0) at_top"
    proof (cases "even k")
      assume "even k"
      hence "\<exists>k'. k = 2 * k'" by (subst (asm) even_mult_two_ex)
      then obtain k' where **: "k = 2 * k'" ..     
      have a: "?f6 = (\<lambda>y. ?f5 k' y * (1 / y))" 
        by (subst **, rule ext) (simp add: field_simps power2_eq_square exp_minus inverse_eq_divide 
          power_mult power_mult_distrib)
      show ?thesis
        apply (subst a, rule tendsto_mult_zero [OF *])
        apply (rule tendsto_divide_0, auto)
        by (rule filterlim_mono [OF _ at_top_le_at_infinity order_refl], rule filterlim_ident)
    next 
      assume "odd k"
      hence "\<exists>k'. k = Suc (2 * k')" by (subst (asm) odd_Suc_mult_two_ex)
      then obtain k' where **: "k = Suc (2 * k')" ..     
      have a: "?f6 = ?f5 k'" 
        by (subst **, rule ext) (simp add: field_simps power2_eq_square exp_minus inverse_eq_divide 
          power_mult power_mult_distrib)
      show ?thesis
        by (subst a, rule *)
    qed
    show ?thesis
      by (subst divide_real_def, rule tendsto_mult_left_zero [OF **])
  qed
  have 4: "(?f1 ---> (k + 1) / 2 * ?f2_lim) at_top"
    apply (subst filterlim_cong [OF refl refl 1])
    apply (subgoal_tac "(k + 1) / 2 * ?f2_lim = (k + 1) / 2 * ?f2_lim - 0")
    apply (erule ssubst)
    apply (rule tendsto_diff [OF _ 3])
    by (rule tendsto_mult [OF _ 2], auto)
  let ?f7 = "(\<lambda>x. exp (- x\<^sup>2) * x ^ (k + 2) * indicator {0..} (x::real))"
  have 5: "(\<lambda>y. LBINT x:{..y}. ?f7 x) = ?f1"
    by (rule ext, rule integral_cong) (auto split: split_indicator)
  have 6: "AE x in lborel. 0 \<le> ?f7 x"
    apply (rule AE_I2, subst mult_assoc, rule mult_nonneg_nonneg)
    by (auto split: split_indicator simp del: power_Suc intro!: zero_le_even_power)
  have 7: "\<And>y. set_integrable lborel {..y} ?f7"
  proof -
    fix y :: real
    have "(\<lambda>x. exp (- x\<^sup>2) * x ^ (k + 2) * indicator {0..} x * indicator {..y} x) =
          (\<lambda>x. exp (- x\<^sup>2) * x ^ (k + 2) * indicator {0..y} x)" 
      by (rule ext, simp split: split_indicator)
    thus "set_integrable lborel {..y} (\<lambda>x. exp (- x\<^sup>2) * x ^ (k + 2) * indicator {0..} x)" 
      apply (elim ssubst)
      by (rule borel_integrable_atLeastAtMost, auto)
  qed
  have 8: "((\<lambda>y. LBINT x:{..y}. ?f7 x) ---> (k + 1) / 2 * ?f2_lim) at_top"
    by (subst 5, rule 4)
  show "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * x ^(k + 2))"
    by (rule integral_monotone_convergence_at_top [OF _ 6 _ 7 8], auto)
  show "(LBINT x:{0..}. exp (- x\<^sup>2) * x ^ (k + 2)) = 
      (k + 1) / 2 * (LBINT x:{0..}. exp (- x\<^sup>2) * x ^ k)"
    by (rule integral_monotone_convergence_at_top [OF _ 6 _ 7 8], auto)
qed
    
lemma aux3_even:
  fixes k :: nat
  shows 
    "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k))" (is "?P k")
  and 
    "(LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k))) = (sqrt pi / 2) * 
        (fact (2 * k) / (2^(2 * k) * fact k))" (is "?Q k")
proof (induct k)
  show "?P 0"
    by (auto intro: integral_exp_neg_x_squared)
  show "?Q 0"
    by (auto simp add: integral_exp_neg_x_squared)
next
  fix k
  assume ihP: "?P k" and ihQ: "?Q k"
  have *: "2 * Suc k = 2 * k + 2" by simp
  show "?P (Suc k)"
    by (subst *, rule aux2 [OF ihP])
  have "(LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 2)))
      = (2 * k + 1) / 2 * (LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k)))"
    by (rule aux2 [OF ihP])
  also have "\<dots> = (2 * k + 1) / 2 * ((sqrt pi / 2) * (fact (2 * k) / (2^(2 * k) * fact k)))"
    by (subst ihQ, rule refl)
  (* Q: could this calculation be done automatically? *)
  also have "\<dots> = sqrt pi / 2 * ((2 * k + 1) / 2 * (fact (2 * k) / (2^(2 * k) * fact k)))"
    by auto
  also have "(2 * k + 1) / 2 * (fact (2 * k) / (2^(2 * k) * fact k)) = 
      (2 * k + 1) * fact (2 * k) / (2^(2 * k + 1) * fact k)"
    apply (subst times_divide_times_eq)
    apply (subst real_of_nat_mult)+
    by simp
  also have "(2 * k + 1) * fact (2 * k) = fact (2 * k + 1)"
    by auto
  also have "fact (2 * k + 1) = fact (2 * k + 2) / (2 * k + 2)"
    by (simp add: field_simps real_of_nat_Suc)
  finally show "?Q (Suc k)" by (simp add: field_simps real_of_nat_Suc)
qed

lemma aux3_odd:
  fixes k :: nat
  shows 
    "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k + 1))" (is "?P k")
  and
    "(LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) =  fact k / 2" (is "?Q k") 
proof (induct k)
  show "?P 0"
    apply (simp, subst mult_commute)
    by (rule integral_x_exp_neg_x_squared)
  show "?Q 0"
    apply (simp, subst mult_commute)
    by (subst integral_x_exp_neg_x_squared, simp)
next
  fix k
  assume ihP: "?P k" and ihQ: "?Q k"
  have *: "2 * Suc k + 1 = (2 * k + 1) + 2" by simp
  show "?P (Suc k)"
    by (subst *, rule aux2 [OF ihP])
  have "(LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 1 + 2)))
      = (2 * k + 1 + 1) / 2 * (LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 1)))"
    by (rule aux2 [OF ihP])
  also have "\<dots> = (2 * k + 1 + 1) / 2 * (fact k / 2)"
    by (subst ihQ, rule refl)
  also have "\<dots> = (k + 1) * fact k / 2" by (simp add: real_of_nat_Suc field_simps)
  also have "\<dots> = fact (k + 1) / 2" by simp
  finally show "?Q (Suc k)" by simp
qed

lemma aux3_odd_abs:
  fixes k :: nat
  shows 
    "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * (abs x) ^ (2 * k + 1))"
  and
    "(LBINT x:{0..}. exp (- x\<^sup>2) * ((abs x) ^ (2 * k + 1))) =  fact k / 2"
proof -
  have *: "\<And>(x :: real) k. exp (- x\<^sup>2) * (abs x) ^ (2 * k + 1) * indicator {0..} x = 
          exp (- x\<^sup>2) * x ^ (2 * k + 1) * indicator {0..} x"
    by (simp split: split_indicator)
  show "set_integrable lborel {0..} (\<lambda>x. exp (- x\<^sup>2) * (abs x) ^ (2 * k + 1))"
    by (subst *, rule aux3_odd)
  show "(LBINT x:{0..}. exp (- x\<^sup>2) * ((abs x) ^ (2 * k + 1))) = fact k / 2"
    by (subst *, rule aux3_odd)
qed

lemma aux4_even:
  fixes k :: nat
  shows 
    "integrable lborel (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k))"
  and 
    "(LBINT x. exp (- x\<^sup>2) * (x ^ (2 * k))) = sqrt pi * (fact (2 * k) / (2^(2 * k) * fact k))"
proof -
  note 1 = aux3_even (1) [of k]
  note 2 = aux3_even (2) [of k]
  have 3: "(\<lambda>x :: real. exp (- x\<^sup>2) * x ^ (2 * k) * indicator {..0} (- x)) =
           (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k) * indicator {0..} x)"
    by (rule ext, auto split: split_indicator)
  have 4: "set_integrable lborel {..0} (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k))"
    by (subst integrable_affine [of "-1" _ 0], simp_all add: 1 3)
  have 5: "(LBINT x:{..0}. exp (- x\<^sup>2) * (x ^ (2 * k))) = (sqrt pi / 2) * 
        (fact (2 * k) / (2^(2 * k) * fact k))"
    by (subst lebesgue_integral_real_affine [of "-1" _ 0], auto simp add: 2 3)
  have 6: "set_integrable lborel {..<0} (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k))"
    apply (subst integrable_cong_AE)
    prefer 4 apply (rule 4)
    by (auto intro!: AE_I [where N="{0}"] split: split_indicator)
  have 7: "(LBINT x:{..<0}. exp (- x\<^sup>2) * (x ^ (2 * k))) = (sqrt pi / 2) * 
        (fact (2 * k) / (2^(2 * k) * fact k))"
    apply (subst 5 [symmetric])
    apply (rule integral_cong_AE)
    by (auto intro!: AE_I [where N="{0}"] split: split_indicator)
  have 8: "(\<lambda>x::real. exp (- x\<^sup>2) * (x ^ (2 * k))) = 
      (\<lambda>x. exp (- x\<^sup>2) * (x ^ (2 * k)) * indicator {..<0} x + 
           exp (- x\<^sup>2) * (x ^ (2 * k)) * indicator {0..} x)"
    by (rule ext, auto split: split_indicator)
  show "integrable lborel (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k))"
    by (subst 8, rule integral_add [OF 6 1])
  have "(LBINT x. exp (- x\<^sup>2) * (x ^ (2 * k))) =
      (LBINT x:{..<0}. exp (- x\<^sup>2) * (x ^ (2 * k))) + (LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k)))"
    apply (subst integral_add (2) [symmetric, OF 6 1])
    by (rule integral_cong, auto split: split_indicator)
  also have "\<dots> = sqrt pi * (fact (2 * k) / (2^(2 * k) * fact k))"
    by (simp add: 2 7) 
  finally show "(LBINT x. exp (- x\<^sup>2) * (x ^ (2 * k))) = sqrt pi * 
        (fact (2 * k) / (2^(2 * k) * fact k))" .
qed

lemma aux4_odd:
  fixes k :: nat
  shows 
    "integrable lborel (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k + 1))"
  and 
    "(LBINT x. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) = 0"
proof -
  note 1 = aux3_odd (1) [of k]
  have 3: "(\<lambda>x :: real. exp (- x\<^sup>2) * x ^ (2 * k + 1) * indicator {..0} (- x)) =
           (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k + 1) * indicator {0..} x)"
    by (rule ext, auto split: split_indicator)
  have 4: "set_integrable lborel {..0} (\<lambda>x :: real. exp (- x\<^sup>2) * x ^ (2 * k + 1))"
    apply (subst integrable_affine [of "-1" _ 0], simp_all del: One_nat_def)
    by (subst 3, rule 1)
  have 5: "(LBINT x:{..0}. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) = 
           -(LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 1)))"
    apply (subst lebesgue_integral_real_affine [of "-1" _ 0], simp_all del: One_nat_def)
    apply (subst set_integral_uminus [symmetric])
    by (rule integral_cong, auto split: split_indicator)
  have 6: "set_integrable lborel {..<0} (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k+ 1))"
    apply (subst integrable_cong_AE)
    prefer 4 apply (rule 4)
    by (auto intro!: AE_I [where N="{0}"] split: split_indicator)
  have 7: "(LBINT x:{..<0}. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) = 
           -(LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 1)))"
    apply (subst 5 [symmetric])
    apply (rule integral_cong_AE)
    by (auto intro!: AE_I [where N="{0}"] split: split_indicator)
  have 8: "(\<lambda>x::real. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) = 
      (\<lambda>x. exp (- x\<^sup>2) * (x ^ (2 * k + 1)) * indicator {..<0} x + 
           exp (- x\<^sup>2) * (x ^ (2 * k + 1)) * indicator {0..} x)"
    by (rule ext, auto split: split_indicator)
  show "integrable lborel (\<lambda>x. exp (- x\<^sup>2) * x ^ (2 * k + 1))"
    by (subst 8, rule integral_add [OF 6 1])
  have "(LBINT x. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) =
      (LBINT x:{..<0}. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) + 
      (LBINT x:{0..}. exp (- x\<^sup>2) * (x ^ (2 * k + 1)))"
    apply (subst integral_add (2) [symmetric, OF 6 1])
    by (rule integral_cong, auto split: split_indicator)
  also have "\<dots> = 0"
    by (simp only: 7) 
  finally show "(LBINT x. exp (- x\<^sup>2) * (x ^ (2 * k + 1))) = 0" .
qed

lemma aux4_odd_abs:
  fixes k :: nat
  shows 
    "integrable lborel (\<lambda>x. exp (- x\<^sup>2) * abs x ^ (2 * k + 1))"
  and 
    "(LBINT x. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) = fact k"
proof -
  note 1 = aux3_odd_abs (1) [of k]
  have 3: "(\<lambda>x :: real. exp (- x\<^sup>2) * abs x ^ (2 * k + 1) * indicator {..0} (- x)) =
           (\<lambda>x. exp (- x\<^sup>2) * abs x ^ (2 * k + 1) * indicator {0..} x)"
    by (rule ext, auto split: split_indicator)
  have 4: "set_integrable lborel {..0} (\<lambda>x :: real. exp (- x\<^sup>2) * (abs x) ^ (2 * k + 1))"
    apply (subst integrable_affine [of "-1" _ 0], simp_all del: One_nat_def)
    by (subst 3, rule 1)
  have 5: "(LBINT x:{..0}. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) = 
           (LBINT x:{0..}. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1)))"
    apply (subst lebesgue_integral_real_affine [of "-1" _ 0], simp_all del: One_nat_def)
    by (rule integral_cong, auto split: split_indicator)
  have 6: "set_integrable lborel {..<0} (\<lambda>x. exp (- x\<^sup>2) * abs x ^ (2 * k+ 1))"
    apply (subst integrable_cong_AE)
    prefer 4 apply (rule 4)
    by (auto intro!: AE_I [where N="{0}"] split: split_indicator)
  have 7: "(LBINT x:{..<0}. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) = 
           (LBINT x:{0..}. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1)))"
    apply (subst 5 [symmetric])
    apply (rule integral_cong_AE)
    by (auto intro!: AE_I [where N="{0}"] split: split_indicator)
  have 8: "(\<lambda>x::real. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) = 
      (\<lambda>x. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1)) * indicator {..<0} x + 
           exp (- x\<^sup>2) * (abs x ^ (2 * k + 1)) * indicator {0..} x)"
    by (rule ext, auto split: split_indicator)
  show "integrable lborel (\<lambda>x. exp (- x\<^sup>2) * abs x ^ (2 * k + 1))"
    by (subst 8, rule integral_add [OF 6 1])
  have "(LBINT x. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) =
      (LBINT x:{..<0}. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) + 
      (LBINT x:{0..}. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1)))"
    apply (subst integral_add (2) [symmetric, OF 6 1])
    by (rule integral_cong, auto split: split_indicator)
  also have "\<dots> = fact k"
    by (subst 7, subst aux3_odd_abs, subst aux3_odd_abs, simp)
  finally show "(LBINT x. exp (- x\<^sup>2) * (abs x ^ (2 * k + 1))) = fact k" .
qed

lemma aux5_even:
  fixes k :: nat
  shows 
    "integrable lborel (\<lambda>x. exp (- x\<^sup>2 / 2) * x ^ (2 * k))"
  and
    "(LBINT x. exp (- x\<^sup>2 / 2) * (x ^ (2 * k))) = 
      sqrt (2 * pi) * (fact (2 * k) / (2^k * fact k))"
proof -
  have *: "(\<lambda>x. exp (- ((sqrt 2 * x)\<^sup>2 / 2)) * (sqrt 2 * x) ^ (2 * k)) =
        (\<lambda>x. 2^k * (exp (- x\<^sup>2) * x ^ (2 * k)))"
    by (rule ext, simp add: power_mult_distrib power_mult)
  have **: "(2::real)^(2 * k) = 2^k * 2^k"
    by (simp add: power_add [symmetric])
  show "integrable lborel (\<lambda>x. exp (- x\<^sup>2 / 2) * x ^ (2 * k))"
    apply (subst integrable_affine [where t = 0 and c = "sqrt 2"], auto simp add: divide_minus_left)
    by (subst *, rule integral_cmult (1), rule aux4_even)
  show 
    "(LBINT x. exp (- x\<^sup>2 / 2) * (x ^ (2 * k))) = 
      sqrt (2 * pi) * (fact (2 * k) / (2^k * fact k))"
    apply (subst lebesgue_integral_real_affine [where t = 0 and c = "sqrt 2"], 
      auto simp add: divide_minus_left)
    apply (subst *, subst integral_cmult, rule aux4_even)
    by (subst aux4_even, simp add: real_sqrt_mult **)
qed

lemma aux5_odd:
  fixes k :: nat
  shows 
    "integrable lborel (\<lambda>x. exp (- x\<^sup>2 / 2) * x ^ (2 * k + 1))" 
  and   
    "(LBINT x. exp (- x\<^sup>2 / 2) * (x ^ (2 * k + 1))) = 0"
proof -
  have *: "(\<lambda>x. exp (- ((sqrt 2 * x)\<^sup>2 / 2)) * (sqrt 2 * x) ^ (2 * k + 1)) =
        (\<lambda>x. 2^k * sqrt 2 * (exp (- x\<^sup>2) * x ^ (2 * k + 1)))"
    by (rule ext, simp add: power_mult_distrib power_mult)

  show "integrable lborel (\<lambda>x. exp (- x\<^sup>2 / 2) * x ^ (2 * k + 1))"
    apply (subst integrable_affine [where t = 0 and c = "sqrt 2"], auto 
      simp del: One_nat_def simp add: divide_minus_left)
    by (subst *, rule integral_cmult (1), rule aux4_odd)
  show 
    "(LBINT x. exp (- x\<^sup>2 / 2) * (x ^ (2 * k + 1))) = 0"
    apply (subst lebesgue_integral_real_affine [where t = 0 and c = "sqrt 2"], 
      auto simp del: One_nat_def simp add: divide_minus_left)
    apply (subst *, subst integral_cmult, rule aux4_odd)
    by (subst aux4_odd, simp add: real_sqrt_mult)
qed

lemma aux5_odd_abs:
  fixes k :: nat
  shows 
    "integrable lborel (\<lambda>x. exp (- x\<^sup>2 / 2) * abs x ^ (2 * k + 1))"
  and
    "(LBINT x. exp (- x\<^sup>2 / 2) * (abs x ^ (2 * k + 1))) = fact k * (2 ^ (k + 1))"
proof -
  have *: "(\<lambda>x. exp (- ((sqrt 2 * x)\<^sup>2 / 2)) * abs (sqrt 2 * x) ^ (2 * k + 1)) =
        (\<lambda>x. (sqrt 2)^(2 *k + 1) * (exp (- x\<^sup>2) * abs x ^ (2 * k + 1)))"
    by (rule ext, simp add: power_mult_distrib abs_mult power_mult)
  have **: "(2::real)^(2 * k) = 2^k * 2^k"
    by (simp add: power_add [symmetric])
  show "integrable lborel (\<lambda>x. exp (- x\<^sup>2 / 2) * abs x ^ (2 * k + 1))"
    apply (subst integrable_affine [where t = 0 and c = "sqrt 2"])
    apply (simp_all del: One_nat_def power_Suc add: divide_minus_left)
    by (subst *, rule integral_cmult (1), rule aux4_odd_abs)
  show 
    "(LBINT x. exp (- x\<^sup>2 / 2) * (abs x ^ (2 * k + 1))) = fact k * (2 ^ (k + 1))"
    apply (subst lebesgue_integral_real_affine [where t = 0 and c = "sqrt 2"])
    apply (simp_all del: One_nat_def power_Suc add: divide_minus_left)
    apply (subst *, subst integral_cmult, rule aux4_odd_abs)
    apply (subst aux4_odd_abs, simp add: power_mult real_sqrt_mult)
    done
qed

(* which is more convenient? *)
abbreviation standard_normal_distribution where
  "standard_normal_distribution \<equiv> density lborel standard_normal_density"

(* a reality check *)
lemma distributed_standard_normal_density: 
  "distributed standard_normal_distribution lborel (\<lambda>x. x) standard_normal_density"
  unfolding distributed_def apply auto
  apply (subst density_distr [symmetric], auto)
by (auto intro!: AE_I2 normal_non_negative)

lemma standard_normal_distribution_even_moments:
  fixes k :: nat
  shows "integrable standard_normal_distribution (\<lambda>x. x ^ (2 * k))"
    "LINT x | standard_normal_distribution. x ^ (2 * k) = (fact (2 * k) / (2^k * fact k))"

  apply (subst integral_density)
  apply (auto intro!: AE_I2 normal_non_negative) [4]
  apply (subst standard_normal_density_def)
  apply (subst mult_assoc, rule integral_cmult (1)) 
  apply (rule aux5_even) 

  apply (subst integral_density)
  apply (auto intro!: AE_I2 normal_non_negative) [4]
  apply (subst standard_normal_density_def)
  apply (subst mult_assoc, subst integral_cmult (2))
  apply (rule aux5_even (1))
by (subst aux5_even (2), auto)

lemma standard_normal_distribution_even_moments_abs:
  fixes k :: nat
  shows "integrable standard_normal_distribution (\<lambda>x. abs x ^ (2 * k))"
    "LINT x | standard_normal_distribution. abs x ^ (2 * k) = (fact (2 * k) / (2^k * fact k))"
proof -
  have *: "\<And>(x :: real) k. abs x ^ (2 * k) = x ^ (2 * k)"
    by (simp add: power_mult)
  show "integrable standard_normal_distribution (\<lambda>x. abs x ^ (2 * k))"
    by (subst *, rule standard_normal_distribution_even_moments)
  show "LINT x | standard_normal_distribution. abs x ^ (2 * k) = 
      (fact (2 * k) / (2^k * fact k))"
    by (subst *, rule standard_normal_distribution_even_moments)
qed

lemma standard_normal_distribution_odd_moments:
  fixes k :: nat
  shows "integrable standard_normal_distribution (\<lambda>x. x ^ (2 * k + 1))"
    "LINT x | standard_normal_distribution. x ^ (2 * k + 1) = 0"

  apply (subst integral_density)
  apply (auto intro!: AE_I2 normal_non_negative) [3]
  apply (subst standard_normal_density_def)
  apply (subst mult_assoc, rule integral_cmult (1)) 
  apply (rule aux5_odd) 

  apply (subst integral_density)
  apply (auto intro!: AE_I2 normal_non_negative simp del: One_nat_def)
  unfolding standard_normal_density_def
  apply (subst mult_assoc, subst integral_cmult (2))
  apply (rule aux5_odd (1))
by (subst aux5_odd (2), auto)

lemma standard_normal_distribution_odd_moments_abs :
  fixes k :: nat
  shows "integrable standard_normal_distribution (\<lambda>x. abs x ^ (2 * k + 1))"
    "LINT x | standard_normal_distribution. abs x ^ (2 * k + 1) = 
      fact k * (2 ^ (k + 1)) / sqrt (2 * pi)"

  apply (subst integral_density)
  apply (auto intro!: AE_I2 normal_non_negative) [3]
  apply (subst standard_normal_density_def)
  apply (subst mult_assoc, rule integral_cmult (1)) 
  apply (rule aux5_odd_abs) 

  apply (subst integral_density)
  apply (auto intro!: AE_I2 normal_non_negative simp del: One_nat_def)
  unfolding standard_normal_density_def
  apply (subst mult_assoc, subst integral_cmult (2))
  apply (rule aux5_odd_abs (1))
by (subst aux5_odd_abs (2), auto)


(* I am uncertain as to which forms are better *)

lemma (in prob_space) standard_normal_distributed_even_moments:
  fixes k :: nat
  assumes D: "distributed M lborel X standard_normal_density"
  shows "expectation (\<lambda>x. (X x)^(2 * k)) = (fact (2 * k) / (2^k * fact k))"

  apply (subst distributed_integral[OF D, of "\<lambda>x. x^(2 * k)", symmetric], auto)
(* or:
  apply (subst integral_density [symmetric])
  apply (auto intro!: AE_I2 normal_non_negative)
  apply (subst standard_normal_distributed_even_moments', auto)
*)
  unfolding standard_normal_density_def
  apply (subst mult_assoc, subst integral_cmult (2))
  apply (rule aux5_even (1))
by (subst aux5_even (2), auto)

lemma (in prob_space) standard_normal_distributed_odd_moments:
  fixes k :: nat
  assumes D: "distributed M lborel X standard_normal_density"
  shows "expectation (\<lambda>x. (X x)^(2 * k + 1)) = 0"

  apply (subst distributed_integral[OF D, of "\<lambda>x. x^(2 * k + 1)", symmetric], force)
  unfolding standard_normal_density_def
  apply (subst mult_assoc, subst integral_cmult (2))
  apply (rule aux5_odd (1))
by (subst aux5_odd (2), auto)


end
