____ReadArray:
	BeginFunc 172 ;
	_tmp0 = "How many scores? " ;
	PushParam _tmp0 ;
	LCall _PrintString ;
	PopParams 4 ;
	_tmp1 = LCall _ReadInteger ;
	numScores = _tmp1 ;
	_tmp2 = 4 ;
	_tmp3 = 0 ;
	_tmp4 = numScores < _tmp3 ;
	_tmp5 = numScores == _tmp3 ;
	_tmp6 = _tmp4 || _tmp5 ;
	IfZ _tmp6 Goto _L0 ;
	_tmp7 = "Decaf runtime error: Array size is <= 0\n" ;
	PushParam _tmp7 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L0:
	_tmp8 = numScores * _tmp2 ;
	_tmp9 = _tmp2 + _tmp8 ;
	PushParam _tmp9 ;
	_tmp10 = LCall _Alloc ;
	PopParams 4 ;
	*(_tmp10) = numScores ;
	arr = _tmp10 ;
	_tmp11 = 0 ;
	i = _tmp11 ;
_L1:
	_tmp12 = *(arr) ;
	_tmp13 = i < _tmp12 ;
	IfZ _tmp13 Goto _L2 ;
	_tmp14 = "Enter next number: " ;
	PushParam _tmp14 ;
	LCall _PrintString ;
	PopParams 4 ;
	_tmp15 = LCall _ReadInteger ;
	num = _tmp15 ;
	_tmp16 = 0 ;
	_tmp17 = *(arr) ;
	_tmp18 = i < _tmp16 ;
	_tmp19 = _tmp17 < i ;
	_tmp20 = _tmp17 == i ;
	_tmp21 = _tmp19 || _tmp20 ;
	_tmp22 = _tmp21 || _tmp18 ;
	IfZ _tmp22 Goto _L3 ;
	_tmp23 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp23 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L3:
	_tmp24 = 4 ;
	_tmp25 = i * _tmp24 ;
	_tmp26 = _tmp25 + _tmp24 ;
	_tmp27 = arr + _tmp26 ;
	*(_tmp27) = num ;
	_tmp28 = *(_tmp27) ;
	_tmp29 = 1 ;
	_tmp30 = i + _tmp29 ;
	i = _tmp30 ;
	Goto _L1 ;
_L2:
	Return arr ;
	EndFunc ;
____Sort:
	BeginFunc 400 ;
	_tmp31 = 1 ;
	i = _tmp31 ;
_L4:
	_tmp32 = *(arr) ;
	_tmp33 = i < _tmp32 ;
	IfZ _tmp33 Goto _L5 ;
	_tmp34 = 1 ;
	_tmp35 = i - _tmp34 ;
	j = _tmp35 ;
	_tmp36 = 0 ;
	_tmp37 = *(arr) ;
	_tmp38 = i < _tmp36 ;
	_tmp39 = _tmp37 < i ;
	_tmp40 = _tmp37 == i ;
	_tmp41 = _tmp39 || _tmp40 ;
	_tmp42 = _tmp41 || _tmp38 ;
	IfZ _tmp42 Goto _L6 ;
	_tmp43 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp43 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L6:
	_tmp44 = 4 ;
	_tmp45 = i * _tmp44 ;
	_tmp46 = _tmp45 + _tmp44 ;
	_tmp47 = arr + _tmp46 ;
	_tmp48 = *(_tmp47) ;
	val = _tmp48 ;
_L7:
	_tmp49 = 0 ;
	_tmp50 = _tmp49 < j ;
	_tmp51 = _tmp49 == j ;
	_tmp52 = _tmp50 || _tmp51 ;
	IfZ _tmp52 Goto _L8 ;
	_tmp53 = 0 ;
	_tmp54 = *(arr) ;
	_tmp55 = j < _tmp53 ;
	_tmp56 = _tmp54 < j ;
	_tmp57 = _tmp54 == j ;
	_tmp58 = _tmp56 || _tmp57 ;
	_tmp59 = _tmp58 || _tmp55 ;
	IfZ _tmp59 Goto _L11 ;
	_tmp60 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp60 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L11:
	_tmp61 = 4 ;
	_tmp62 = j * _tmp61 ;
	_tmp63 = _tmp62 + _tmp61 ;
	_tmp64 = arr + _tmp63 ;
	_tmp65 = *(_tmp64) ;
	_tmp66 = _tmp65 < val ;
	_tmp67 = _tmp65 == val ;
	_tmp68 = _tmp66 || _tmp67 ;
	IfZ _tmp68 Goto _L9 ;
	Goto _L8 ;
	Goto _L10 ;
_L9:
_L10:
	_tmp69 = 0 ;
	_tmp70 = *(arr) ;
	_tmp71 = j < _tmp69 ;
	_tmp72 = _tmp70 < j ;
	_tmp73 = _tmp70 == j ;
	_tmp74 = _tmp72 || _tmp73 ;
	_tmp75 = _tmp74 || _tmp71 ;
	IfZ _tmp75 Goto _L12 ;
	_tmp76 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp76 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L12:
	_tmp77 = 4 ;
	_tmp78 = j * _tmp77 ;
	_tmp79 = _tmp78 + _tmp77 ;
	_tmp80 = arr + _tmp79 ;
	_tmp81 = *(_tmp80) ;
	_tmp82 = 1 ;
	_tmp83 = j + _tmp82 ;
	_tmp84 = 0 ;
	_tmp85 = *(arr) ;
	_tmp86 = _tmp83 < _tmp84 ;
	_tmp87 = _tmp85 < _tmp83 ;
	_tmp88 = _tmp85 == _tmp83 ;
	_tmp89 = _tmp87 || _tmp88 ;
	_tmp90 = _tmp89 || _tmp86 ;
	IfZ _tmp90 Goto _L13 ;
	_tmp91 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp91 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L13:
	_tmp92 = 4 ;
	_tmp93 = _tmp83 * _tmp92 ;
	_tmp94 = _tmp93 + _tmp92 ;
	_tmp95 = arr + _tmp94 ;
	*(_tmp95) = _tmp81 ;
	_tmp96 = *(_tmp95) ;
	_tmp97 = 1 ;
	_tmp98 = j - _tmp97 ;
	j = _tmp98 ;
	Goto _L7 ;
_L8:
	_tmp99 = 1 ;
	_tmp100 = j + _tmp99 ;
	_tmp101 = 0 ;
	_tmp102 = *(arr) ;
	_tmp103 = _tmp100 < _tmp101 ;
	_tmp104 = _tmp102 < _tmp100 ;
	_tmp105 = _tmp102 == _tmp100 ;
	_tmp106 = _tmp104 || _tmp105 ;
	_tmp107 = _tmp106 || _tmp103 ;
	IfZ _tmp107 Goto _L14 ;
	_tmp108 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp108 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L14:
	_tmp109 = 4 ;
	_tmp110 = _tmp100 * _tmp109 ;
	_tmp111 = _tmp110 + _tmp109 ;
	_tmp112 = arr + _tmp111 ;
	*(_tmp112) = val ;
	_tmp113 = *(_tmp112) ;
	_tmp114 = 1 ;
	_tmp115 = i + _tmp114 ;
	i = _tmp115 ;
	Goto _L4 ;
_L5:
	EndFunc ;
____PrintArray:
	BeginFunc 100 ;
	_tmp116 = 0 ;
	i = _tmp116 ;
	_tmp117 = "Sorted results: " ;
	PushParam _tmp117 ;
	LCall _PrintString ;
	PopParams 4 ;
_L15:
	_tmp118 = *(arr) ;
	_tmp119 = i < _tmp118 ;
	IfZ _tmp119 Goto _L16 ;
	_tmp120 = 0 ;
	_tmp121 = *(arr) ;
	_tmp122 = i < _tmp120 ;
	_tmp123 = _tmp121 < i ;
	_tmp124 = _tmp121 == i ;
	_tmp125 = _tmp123 || _tmp124 ;
	_tmp126 = _tmp125 || _tmp122 ;
	IfZ _tmp126 Goto _L17 ;
	_tmp127 = "Decaf runtime error: Array subscript out of bound..." ;
	PushParam _tmp127 ;
	LCall _PrintString ;
	PopParams 4 ;
	LCall _Halt ;
_L17:
	_tmp128 = 4 ;
	_tmp129 = i * _tmp128 ;
	_tmp130 = _tmp129 + _tmp128 ;
	_tmp131 = arr + _tmp130 ;
	_tmp132 = *(_tmp131) ;
	PushParam _tmp132 ;
	LCall _PrintInt ;
	PopParams 4 ;
	_tmp133 = " " ;
	PushParam _tmp133 ;
	LCall _PrintString ;
	PopParams 4 ;
	_tmp134 = 1 ;
	_tmp135 = i + _tmp134 ;
	i = _tmp135 ;
	Goto _L15 ;
_L16:
	_tmp136 = "\n" ;
	PushParam _tmp136 ;
	LCall _PrintString ;
	PopParams 4 ;
	EndFunc ;
main:
	BeginFunc 24 ;
	_tmp137 = "\nThis program will read in a bunch of numbers an..." ;
	PushParam _tmp137 ;
	LCall _PrintString ;
	PopParams 4 ;
	_tmp138 = "back out in sorted order.\n\n" ;
	PushParam _tmp138 ;
	LCall _PrintString ;
	PopParams 4 ;
	_tmp139 = LCall ____ReadArray ;
	arr = _tmp139 ;
	PushParam arr ;
	LCall ____Sort ;
	PopParams 4 ;
	PushParam arr ;
	LCall ____PrintArray ;
	PopParams 4 ;
	EndFunc ;