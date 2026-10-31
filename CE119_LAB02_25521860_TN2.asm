.data
	scores:		.word 6 3 8 9 2 5 7 2 6 9 4 3
	grade_tab:	.byte 0 0 0 0 1 1 1 2 2 3 3	
	hist: 		.word 0 0 0 0
	n_scores: 	.word 12

	str_min:	.asciiz "min="
	str_max:	.asciiz " max="
	str_g0:		.asciiz "g0="		
	str_g1:		.asciiz " g1="	
	str_g2:		.asciiz " g2="
	str_g3:		.asciiz " g3="
	str_nl:		.asciiz "\n"

.text

main:
# Goi stats va in ket qua
	la $a0, scores
	lw $a1, n_scores
	jal stats
	
	move $s0, $v0
	move $s1, $v1
	
	li $v0, 4
	la $a0, str_min
	syscall
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 4
	la $a0, str_max
	syscall
	li $v0, 1
	move $a0, $s1
	syscall
	
	li $v0, 4
	la $a0, str_nl
	syscall
	
#Goi histogram va in ket qua
	la $a0, scores
	lw $a1, n_scores
	la $a2, grade_tab
	la $a3, hist
	jal histogram
	
	la $t0, hist
	
	li $v0, 4
	la $a0, str_g0
	syscall
	lw $a0, 0($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_g1
	syscall
	lw $a0, 4($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_g2
	syscall
	lw $a0, 8($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_g3
	syscall
	lw $a0, 12($t0)
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, str_nl
	syscall
	
	li $v0, 10
	syscall

# ===================================================================
# THU TUC: stats
# Muc dich:   Duyet mang diem sinh vien de tim gia tri Min va Max
# Tham so:    $a0 = Dia chi goc cua mang diem (.word)
#             $a1 = So luong sinh vien N (N > 0)
# Tra ve:     $v0 = Gia tri Min
#             $v1 = Gia tri Max
# Thanh ghi su dung:
#             $a0 : Con tro duyet mang diem (tang 4 byte sau moi vong)
#             $a1 : Bien dem lui so phan tu con lai (giam dan ve 0)
#             $v0 : Luu gia tri Min trong qua trinh duyet
#             $v1 : Luu gia tri Max trong qua trinh duyet
#             $t0 : Luu gia tri diem vua doc tu mang (scores[i])
# Quy uc:     Chi su dung thanh ghi tam $t0, thanh ghi tham so $a0-$a1 va thanh ghi tra ve $v0-$v1.
# ===================================================================

stats: 
	lw $v0, 0($a0)
	move $v1, $v0
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	
stats_loop:
	beq $a1, $zero, stats_done
	
	lw $t0, 0($a0)
	
	bge $t0, $v0, stats_check_max
	move $v0, $t0

stats_check_max:
	ble $t0, $v1, stats_next
	move $v1, $t0

stats_next:
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	j stats_loop
	
stats_done:
	jr $ra
	
# ===================================================================
# THU TUC: histogram
# Muc dich:   Duyet mang diem, tra cuu phan nhom
#             va cap nhat so luong sinh vien tuong ung vao mang hist.
# Tham so:    $a0 = Dia chi goc mang diem (.word)
#             $a1 = So luong sinh vien N (dem lui ve 0)
#             $a2 = Dia chi goc mang grade_tab (.byte)
#             $a3 = Dia chi goc mang hist (.word)
# Tra ve:     Khong co. Cap nhat truc tiep ket qua vao mang hist
# Thanh ghi su dung:
#             $a0 : Con tro duyet mang diem (tang 4 byte sau moi vong)
#             $a1 : Bien dem so phan tu con lai (giam 1 sau moi vong)
#             $a2 : Dia chi goc mang grade_tab
#             $a3 : Dia chi goc mang hist
#             $t0 : Gia tri diem doc tu mang scores (scores[i])
#             $t1 : Dia chi o nho tuong ung trong mang grade_tab ($a2 + $t0)
#             $t2 : Ma nhom thu duoc tu mang grade_tab (doc bang lbu)
#             $t3 : Dia chi phan tu nhom tuong ung trong mang hist ($a3 + $t2 * 4)
#             $t4 : Gia tri dem hien tai cua nhom trong hist (de cong them 1)
# Quy uc:     Chi su dung cac thanh ghi tham so $a0-$a3 va cac thanh ghi tam $t0-$t4.
# ===================================================================

histogram:
hist_loop:
	beq $a1, $zero, hist_done
	
	lw $t0, 0($a0)
	add $t1, $a2, $t0
	lbu $t2, 0($t1)
	
	sll $t3, $t2, 2
	add $t3, $a3, $t3
	lw $t4, 0($t3)
	addi $t4, $t4, 1
	sw $t4, 0($t3)
	
	addi $a0, $a0, 4
	addi $a1, $a1, -1
	j hist_loop

hist_done:
	jr $ra

	
	
