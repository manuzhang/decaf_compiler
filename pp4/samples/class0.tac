__A.fn:
	BeginFunc 4 ;
	y = x ;
	EndFunc ;
VTable A =
	__A.fn,
; 
main:
	BeginFunc 20 ;
	_tmp0 = 4 ;
	PushParam _tmp0 ;
	a = LCall _Alloc ;
	PopParams 4 ;
	_tmp1 = *(a) ;
	_tmp2 = *(_tmp1) ;
	_tmp3 = 137 ;
	PushParam _tmp3 ;
	PushParam a ;
	ACall _tmp2 ;
	PopParams 8 ;
	EndFunc ;
