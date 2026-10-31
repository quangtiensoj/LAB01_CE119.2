.data
   	# test_str: .asciiz "(a+b)*[c-{d/e}]"   
    	# test_str: .asciiz "f(x[i]{j}))"        
    	# test_str: .asciiz "{[()]}"             
    	# test_str: .asciiz "((a)"     
    	test_str: .asciiz "([{}])"            

    	msg_str:    .asciiz "Chuoi kiem tra: "
    	msg_v0:     .asciiz "\n$v0 =  "
    	msg_v1:     .asciiz "\n$v1 = "
    	msg_nl:     .asciiz "\n"
 
.text

main:
    	# In chuoi ra
    	li      $v0, 4
    	la      $a0, msg_str
    	syscall
    	la      $a0, test_str
    	syscall
	
	# Goi thu tuc check_brackets
    	la      $a0, test_str       
    	jal     check_brackets      

    	# Luu ket qua
    	move    $s0, $v0
    	move    $s1, $v1

    	# In ket qua $v0
    	li      $v0, 4
    	la      $a0, msg_v0
    	syscall
    	li      $v0, 1
    	move    $a0, $s0
    	syscall

    	# In ket qua $v1
    	li      $v0, 4
    	la      $a0, msg_v1
    	syscall
    	li      $v0, 1
    	move    $a0, $s1
    	syscall


    	li      $v0, 10
    	syscall
    	
# ===================================================================
# THU TUC: check_brackets
# Muc dich:   Kiem tra tinh hop le cua cac cap ngoac (), [], {}
# Tham so:    $a0 = Dia chi con tro chuoi ky tu ket thuc bang '\0' (.asciiz)
# Tra ve:     $v0 = Vi tri ky tu bi loi (dem tu 1) / 0 neu chuoi hop le / N+1 neu thieu ngoac dong
#             $v1 = Ma loi:
#                   0: Chuoi hop le
#                   1: Ngoac dong khong cung loai voi ngoac mo o dinh ngan xep
#                   2: Gap ngoac dong khi ngan xep rong
#                   3: Het chuoi nhung ngan xep van con ngoac mo
# Thanh ghi su dung:
#             $a0 : Con tro duyet chuoi (tang 1 byte sau moi ky tu)
#             $v0 : Luu vi tri loi / ket qua tra ve
#             $v1 : Luu ma loi tra ve (0, 1, 2, 3)
#             $t0 : Dem vi tri ky tu hien tai trong chuoi (bat dau tu 1)
#             $t1 : Ky tu ASCII vua doc tu chuoi
#             $t2 : Ma ASCII cac ngoac dung de so sanh
#             $t3 : Ky tu ngoac mo pop tu dinh ngan xep ra de doi chieu
#             $t4 : Ma ASCII ngoac mo ky vong de kiem tra khop cap
#             $t9 : Luu gia tri goc cua $sp ban dau (kiem tra rong va khoi phuc $sp)
#             $sp : Con tro ngan xep (giam/tang 4 byte, ghi de 0 khi pop)
# Quy uc:     Chi su dung thanh ghi tam $t0-$t4, $t9 va thanh ghi tra ve $v0-$v1.
#             Khoi phuc $sp ve $t9 tren moi duong thoat.
# ===================================================================

check_brackets:
	move $t9, $sp
	li $t0, 1

cb_loop:
	lbu $t1, 0($a0)
	beq $t1, $zero, cb_end
	
	#check ngoac mo
	li $t2, 40             
    	beq $t1, $t2, cb_push
    	li $t2, 91             
    	beq $t1, $t2, cb_push
    	li $t2, 123            
    	beq $t1, $t2, cb_push
	
	#check ngoac dong
	li $t2, 41             
   	beq $t1, $t2, cb_check_close
    	li $t2, 93             
    	beq $t1, $t2, cb_check_close
    	li $t2, 125            
    	beq $t1, $t2, cb_check_close
	
	j cb_next

cb_push:
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	j cb_next

cb_check_close:
	beq $sp, $t9, cb_err2
	
	lw $t3, 0($sp)
	sw $zero, 0($sp)
	addi $sp, $sp, 4
	li $t2, 41             
   	beq $t1, $t2, match_round
    	li $t2, 93            
    	beq $t1, $t2, match_square
    	li $t2, 125          
    	beq $t1, $t2, match_curly
    	
match_round:
    	li $t4, 40             
    	bne $t3, $t4, cb_err1   
    	j cb_next

match_square:
    	li $t4, 91             
    	bne $t3, $t4, cb_err1   
    	j cb_next

match_curly:
    	li $t4, 123            
    	bne $t3, $t4, cb_err1   
    	j cb_next
  
cb_next:
	addi $a0, $a0, 1
	addi $t0, $t0, 1
	j cb_loop

cb_end:
	bne $sp, $t9, cb_err3
	
	li $v0, 0
	li $v1, 0
	j cb_exit
	
cb_err1:
	move $v0, $t0
	li $v1, 1
	j cb_exit
	
cb_err2:
	move $v0, $t0
	li $v1, 2
	j cb_exit

cb_err3:
	move $v0, $t0
	li $v1, 3
	j cb_exit

cb_exit:
	move $sp, $t9
	jr $ra
