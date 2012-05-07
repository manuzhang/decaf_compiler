____modify:
	BeginFunc 92 ;
	_tmp0 = 0 ;
	i = _tmp0 ;
_L0:
	_tmp1 = *(a) ;
	_tmp2 = i < _tmp1 ;
	IfZ _tmp2 Goto _L1 ;
	_tmp3 = 0 ;
	_tmp4 = *(a) ;
	_tmp5 = i < _tmp3 ;
	_tmp6 = _tmp4 < i ;
	_tmp7 = _tmp4 == i ;
	_tmp8 = _tmp6 || _tmp7 ;
	_tmp9 = _tmp8 || _tmp5 ;
	IfZ _tmp9 Goto _L2 ;
	_tmp10 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp10 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L2:
	_tmp11 = 4 ;
	_tmp12 = i * _tmp11 ;
	_tmp13 = _tmp12 + _tmp11 ;
	_tmp14 = a + _tmp13 ;
	*(_tmp14) = i ;
	_tmp15 = *(_tmp14) ;
	_tmp16 = 1 ;
	_tmp17 = i + _tmp16 ;
	i = _tmp17 ;
	Goto _L0 ;
_L1:
	EndFunc ;
main:
	BeginFunc 220 ;
	_tmp18 = 5 ;
	_tmp19 = 4 ;
	_tmp20 = 0 ;
	_tmp21 = _tmp18 < _tmp20 ;
	_tmp22 = _tmp18 == _tmp20 ;
	_tmp23 = _tmp21 || _tmp22 ;
	IfZ _tmp23 Goto _L3 ;
	_tmp24 = "Decaf runtime error: Array size is <= 0\n" ;
	PushParam _tmp24 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L3:
	_tmp25 = _tmp18 * _tmp19 ;
	_tmp26 = _tmp19 + _tmp25 ;
	PushParam _tmp26 ;
	_tmp27 = LCall _Alloc ;
	PopParams 4 ;
	*(_tmp27) = _tmp18 ;
	a = _tmp27 ;
	_tmp28 = 0 ;
	i = _tmp28 ;
_L4:
	_tmp29 = *(a) ;
	_tmp30 = i < _tmp29 ;
	IfZ _tmp30 Goto _L5 ;
	_tmp31 = 10 ;
	_tmp32 = i + _tmp31 ;
	_tmp33 = 0 ;
	_tmp34 = *(a) ;
	_tmp35 = i < _tmp33 ;
	_tmp36 = _tmp34 < i ;
	_tmp37 = _tmp34 == i ;
	_tmp38 = _tmp36 || _tmp37 ;
	_tmp39 = _tmp38 || _tmp35 ;
	IfZ _tmp39 Goto _L6 ;
	_tmp40 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp40 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L6:
	_tmp41 = 4 ;
	_tmp42 = i * _tmp41 ;
	_tmp43 = _tmp42 + _tmp41 ;
	_tmp44 = a + _tmp43 ;
	*(_tmp44) = _tmp32 ;
	_tmp45 = *(_tmp44) ;
	_tmp46 = 1 ;
	_tmp47 = i + _tmp46 ;
	i = _tmp47 ;
	Goto _L4 ;
_L5:
	PushParam a ;
	LCall ____modify ;
	PopParams 4 ;
	_tmp48 = 0 ;
	i = _tmp48 ;
_L7:
	_tmp49 = *(a) ;
	_tmp50 = i < _tmp49 ;
	IfZ _tmp50 Goto _L8 ;
	_tmp51 = 0 ;
	_tmp52 = *(a) ;
	_tmp53 = i < _tmp51 ;
	_tmp54 = _tmp52 < i ;
	_tmp55 = _tmp52 == i ;
	_tmp56 = _tmp54 || _tmp55 ;
	_tmp57 = _tmp56 || _tmp53 ;
	IfZ _tmp57 Goto _L9 ;
	_tmp58 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp58 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L9:
	_tmp59 = 4 ;
	_tmp60 = i * _tmp59 ;
	_tmp61 = _tmp60 + _tmp59 ;
	_tmp62 = a + _tmp61 ;
	_tmp63 = *(_tmp62) ;
	PushParam _tmp63 ;
	LCall _PrintInt ;
	PopParams 4 ;
	_tmp64 = 1 ;
	_tmp65 = i + _tmp64 ;
	i = _tmp65 ;
	Goto _L7 ;
_L8:
	EndFunc ;
