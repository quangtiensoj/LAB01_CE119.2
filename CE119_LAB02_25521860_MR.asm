.data
	scores:		.word 6 3 8 9 2 5 7 2 6 9 4 3
	grade_tab:	.byte 0 0 0 0 1 1 1 2 2 3 3	
	hist: 		.word 0 0 0 0
	n_scores: 	.word 12

    	str_g0:     .asciiz "g0: "
    	str_g1:     .asciiz "g1: "
    	str_g2:     .asciiz "g2: "
    	str_g3:     .asciiz "g3: "
    	str_nl:     .asciiz "\n"

    	labels:     .word str_g0, str_g1, str_g2, str_g3

.text
main:
    	# goi histogram
    	la      $a0, scores
    	lw      $a1, n_scores
    	la      $a2, grade_tab      
    	la      $a3, hist
    	jal     histogram

    	# Goi draw_hist
    	la      $a0, hist           # $a0 = dia chi mang hist sau tinh toan
    	li      $a1, 4              # $a1 = so nhóm = 4
    	jal     draw_hist
	
    	li      $v0, 10
    	syscall


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


# ===================================================================
# THU TUC: draw_hist
# Muc dich:   Ve bieu do cot ngang bang ky tu '|' tu du lieu mang hist.
# Tham so:    $a0 = Dia chi mang hist (.word)
#             $a1 = So nhom (4)
# Tra ve:     Khong co. In truc tiep ra cua so Run I/O
# Thanh ghi su dung:
#             $a0 : Truyen dia chi chuoi / ky tu cho syscall
#             $a1 : Nhan so nhom (4)
#             $v0 : Ma lenh syscall (4: in chuoi, 11: in ky tu)
#             $t0 : Dia chi goc mang hist
#             $t1 : Bien dem vong lap ngoai i (0 -> $a1 - 1)
#             $t2 : So sinh vien nhom i (hist[i])
#             $t3 : Bien dem vong lap trong j (so ky tu '|' da in)
#             $t4 : Con tro duyet bang labels (tang 4 byte moi vong)
# Quy uc:     La thu tuc la (Leaf Procedure), bao ton hoan toan $s0-$s7.
# ===================================================================

draw_hist:
    	move $t0, $a0		# $t0 = dia chi mang hist
    	li $t1, 0              # i = 0
 	la $t4, labels
 	
dh_pra:
    	beq $t1, $a1, dh_done   # N?u i == $a1 -> Done

	#in "g_i:" 
    	lw $a0, 0($t4)         
    	li $v0, 4              
    	syscall
    	addi $t4, $t4, 4

    	# doc so luong sinh vien hist[i]
    	sll $t2, $t1, 2
    	add $t2, $t0, $t2
    	lw $t2, 0($t2)         # $t2 = hist[i]

    	# vong lap in |
    	li  $t3, 0              # j = 0

dh_loop:
   	beq $t3, $t2, dh_end  # j == hist[i] ->  ket thuc vong lap

    	li $v0, 11
    	li $a0, 124            # |
    	syscall

    	addi $t3, $t3, 1         # j++
    	j dh_loop

dh_end:
    	li $v0, 4
    	la $a0, str_nl
    	syscall

    	addi $t1, $t1, 1         # i++
    	j dh_pra

dh_done:
    	jr $ra
