(let (CellLibrary pcellId)
  CellLibrary = "sar_adc"
  (unless (ddGetObj CellLibrary)
    (error "Couldn't open library %L" CellLibrary))
  pcellId =  (pcDefinePCell
			  (list (ddGetObj CellLibrary) "switch" "schematic" "schematic" )
			  (
			   (N 1)
			   (W "240n")
			   (L "180n")
			   )

			  (let (pcCV masterCv instName instId netS netI netO)
				pcCV = pcCellView

				nmosCV = (dbOpenCellViewByType "UMC_18_CMOS" "N_18_MM" "symbol" nil "r" )

				numInsts=N
				select = sprintf(nil "S<%d:1>" numInsts)
				netS = dbMakeNet(pcCV select)
				netI = dbMakeNet(pcCV "IN")
				netO = dbMakeNet(pcCV "OUT")

				dbCreateTerm(netS select "input")
				dbCreateTerm(netI "IN" "input")
				dbCreateTerm(netO "OUT" "output")

				when(numInsts<1 numInsts=1)
				for(inst 1 numInsts
						 if(inst==1 then
									netI=dbMakeNet(pcCV "IN")
									else
									netI=dbMakeNet(pcCV sprintf(nil "net%d" inst-1))
									)
						 if(inst==numInsts then
										   netO=dbMakeNet(pcCV "OUT")
										   else
										   netO=dbMakeNet(pcCV sprintf(nil "net%d" inst))
										   )
						 netS=dbMakeNet(pcCV sprintf(nil "S<%d>" inst))
						 netB=dbMakeNet(pcCV sprintf(nil "gnd!" inst))

						 sprintf(instName "M%d" inst)
						 instId = dbCreateParamInst( pcCV nmosCV instName (0:0) "R0" 1
														  (list
														   (list "w" "string" W)
														   (list "l" "string" L)))

						 (let (cdf cdfgData)
	   					   (setq cdf (cdfGetInstCDF instId))
	   					   (setq cdfgData cdf)
	   					   (evalstring cdf~>w~>callback)
	   					   (evalstring cdf~>l~>callback))


						 dbCreateInstTerm(netI instId dbFindTermByName(nmosCV "D"))
						 dbCreateInstTerm(netO instId dbFindTermByName(nmosCV "S"))
						 dbCreateInstTerm(netS instId dbFindTermByName(nmosCV "G"))
						 dbCreateInstTerm(netB instId dbFindTermByName(nmosCV "B"))

						 )

				(dbClose nmosCV)

				t
				)
			  )

  (dbSave pcellId)
  (dbClose pcellId)
  )

(defun createPin (pcCellView name cx cy wirelength dir justify)
  netId = dbCreateNet(pcCellView name)
  dbCreateLine(pcCellView '("device" "drawing") list(cx:cy cx-wirelength:cy))
  dbCreateLabel(pcCellView '("pin" "drawing") cx:cy name justify "R0" "stick" 0.0625)
  dbCreateTerm(netId name dir)
  dbCreatePin(netId dbCreateRect(pcCellView '("pin" "drawing") list(cx-0.025-wirelength:cy-0.025 cx+0.025-wirelength:cy+0.025)))
  )


(let (CellLibrary pcellId)
  CellLibrary = "sar_adc"
  unless( ddGetObj(CellLibrary)
				  error("Couldn't open library %L" CellLibrary)
				  )

  pcellId = (pcDefinePCell
			 list(ddGetObj(CellLibrary) "switch" "symbol" "schematicSymbol")
			 (
			  (N 1)
			  (W "240n")
			  (L "180n")
			  )

			 dbCreateRect(pcCellView
						  '("device" "drawing")
						  list(0.0:0.0 1.0:0.5))
			 dbCreateRect(pcCellView
						  '("instance" "drawing")
						  list(0.0:0.0 1.0:0.5))


			 (createPin pcCellView sprintf(nil "S<%d:1>" N) 0.0 0.375 0.25 "input" "centerLeft")
			 (createPin pcCellView "IN" 0.0 0.125 0.25 "input" "centerLeft")
			 (createPin pcCellView "OUT" 1.0 0.250 -0.25 "output" "centerRight")


			 pcInst = dbCreateLabel(pcCellView '("instance" "label") 0:0.0 "[@instanceName]" "lowerLeft" "R0" "stick" 0.0625)
			 dbSetq(pcInst "NLPLabel" labelType)
			 pcInst = dbCreateLabel(pcCellView '("device" "label") 1.0:0 "[@cellName]" "lowerRight" "R0" "stick" 0.0625)
			 dbSetq(pcInst "NLPLabel" labelType)

			 t
			 )
  (dbSave pcellId)
  (dbClose pcellId)
  )


(let (CellLibrary pcellId)
  CellLibrary = "sar_adc"
  (unless (ddGetObj CellLibrary)
    (error "Couldn't open library %L" CellLibrary))
  pcellId =  (pcDefinePCell
			  (list (ddGetObj CellLibrary) "dac_bit_test" "schematic" "schematic" )
			  (
			   (N 1)
			   (W "240n")
			   (L "180n")
			   (R "10K")
			   )

			  (let (pcCV decoderCV instName instId netS netI netO)
				pcCV = pcCellView

				decoderCV = (dbOpenCellViewByType "sar_adc" "switch" "symbol" nil "r" )
				resCV = (dbOpenCellViewByType "UMC_18_CMOS" "RNHR1000_MM" "symbol" nil "r" )

				select = sprintf(nil "select<%d:1>" N)
				netSelect = dbMakeNet(pcCV select)
				netVdd = dbMakeNet(pcCV "vdd!")
				netVin = dbMakeNet(pcCV "Vin")
				netVout = dbMakeNet(pcCV "Vout")
				netVselect = dbMakeNet(pcCV "Vselect")

				dbCreateTerm(netSelect select "input")
				dbCreateTerm(netVin "Vin" "input")
				dbCreateTerm(netVout "Vout" "output")
				dbCreateTerm(netVselect "Vselect" "output")

				decoderID = (dbCreateParamInst pcCV decoderCV "D0" (0:0) "R0" 1
											   (list
												(list "N" "int" N)
												(list "W" "string" W)
												(list "L" "string" L)))
				resID = (dbCreateParamInst pcCV resCV "R0" (0:0) "R0" 1 (list
																		 (list "w" "string" "180n")
																		 (list "r" "string" R)))

				(let (cdf cdfgData)
				  (setq cdf (cdfGetInstCDF resID))
				  (setq cdfgData cdf)
				  (evalstring cdf~>r~>callback))


				dbCreateInstTerm(netSelect decoderID dbFindTermByName(decoderID~>master (sprintf nil "S<%d:1>" N)))
				dbCreateInstTerm(netVin decoderID dbFindTermByName(decoderID~>master "IN"))
				dbCreateInstTerm(netVselect decoderID dbFindTermByName(decoderID~>master "OUT"))


				dbCreateInstTerm(netVin resID dbFindTermByName(resCV "PLUS"))
				dbCreateInstTerm(netVout resID dbFindTermByName(resCV "MINUS"))
				dbCreateInstTerm(netVdd resID dbFindTermByName(resCV "B"))

				(dbClose decoderCV)
				(dbClose resCV)

				t
				)
			  )

  (dbSave pcellId)
  (dbClose pcellId)
  )

(let (CellLibrary pcellId)
  CellLibrary = "sar_adc"
  unless( ddGetObj(CellLibrary)
				  error("Couldn't open library %L" CellLibrary)
				  )

  pcellId = (pcDefinePCell
			 list(ddGetObj(CellLibrary) "dac_bit_test" "symbol" "schematicSymbol")
			 (
			  (N 1)
			  (W "240n")
			  (L "180n")
			  (R "10K")
			  )

			 dbCreateRect(pcCellView
						  '("device" "drawing")
						  list(0.0:0.0 1.0:0.5))
			 dbCreateRect(pcCellView
						  '("instance" "drawing")
						  list(0.0:0.0 1.0:0.5))


			 (createPin pcCellView sprintf(nil "select<%d:1>" N) 0.0 0.375 0.25 "input" "centerLeft")
			 (createPin pcCellView "Vin" 0.0 0.125 0.25 "input" "centerLeft")
			 (createPin pcCellView "Vout" 1.0 0.125 -0.25 "output" "centerRight")
			 (createPin pcCellView "Vselect" 1.0 0.375 -0.25 "output" "centerRight")


			 pcInst = dbCreateLabel(pcCellView '("instance" "label") 0:0.0 "[@instanceName]" "lowerLeft" "R0" "stick" 0.0625)
			 dbSetq(pcInst "NLPLabel" labelType)
			 pcInst = dbCreateLabel(pcCellView '("device" "label") 1.0:0 "[@cellName]" "lowerRight" "R0" "stick" 0.0625)
			 dbSetq(pcInst "NLPLabel" labelType)

			 t
			 )
  (dbSave pcellId)
  (dbClose pcellId)
  )

(let (CellLibrary pcellId)
  CellLibrary = "sar_adc"
  (unless (ddGetObj CellLibrary)
    (error "Couldn't open library %L" CellLibrary))
  pcellId =  (pcDefinePCell
			  (list (ddGetObj CellLibrary) "dac_test" "schematic" "schematic" )
			  (
			   (N 1)
			   (W "240n")
			   (L "180n")
			   (Vlim "1.2")
			   (I "10u")
			   )


			  (let (pcCV decoderCV instName instId netS netI netO)
				pcCV = pcCellView

				dac_bitCV = (dbOpenCellViewByType "sar_adc" "dac_bit_test" "symbol" nil "r")
				resCV = (dbOpenCellViewByType "UMC_18_CMOS" "RNHR1000_MM" "symbol" nil "r")
				invCV = (dbOpenCellViewByType "sar_adc" "inverter" "symbol" nil "r")

				value = sprintf(nil "value<%d:1>" N)
				netVdd = dbMakeNet(pcCV "vdd!")
				netValue = dbMakeNet(pcCV value)
				netVout = dbMakeNet(pcCV "Vout")
				netVlim = dbMakeNet(pcCV "Vlim")


				Vlim_float = cdfParseFloatString(Vlim)
				I_float = cdfParseFloatString(I)
				Rb = (1.8 - Vlim_float) / I_float
				Ra = Vlim_float / (I_float * (pow 2 N))

				;; U = R * I
				;; 1.8V = (Rb + Ra*2^N) * I
				;; 1.8V / I = (Rb + Ra*2^N)
				;; (1.8 V - Vlim) / I = Rb
				;; Vlim / (I * 2^N) = Ra

				dbCreateTerm(netValue value "input")
				dbCreateTerm(netVout "Vout" "output")


				resBID = (dbCreateParamInst pcCV resCV "RB" (0:0) "R0" 1
											(list
											 (list "w" "string" "180n")
											 (list "r" "string" (sprintf nil "%f" Rb))))

				dbCreateInstTerm(netVdd resBID dbFindTermByName(resCV "PLUS"))
				dbCreateInstTerm(netVlim resBID dbFindTermByName(resCV "MINUS"))
				dbCreateInstTerm(netVdd resBID dbFindTermByName(resCV "B"))

				(let (cdf cdfgData)
				  (setq cdf (cdfGetInstCDF resBID))
				  (setq cdfgData cdf)
				  (evalstring cdf~>r~>callback))



				for(i 1 N
					  id = (dbCreateInst pcCV invCV (sprintf nil "INV%d" i) (0:0) "R0")

					  value_in = sprintf(nil "value<%d>" i)
					  value_inv = sprintf(nil "value_inv<%d>" i)
					  netIn = dbMakeNet(pcCV value_in)
					  netInv = dbMakeNet(pcCV value_inv)

					  dbCreateInstTerm(netIn id dbFindTermByName(invCV "IN"))
					  dbCreateInstTerm(netInv id dbFindTermByName(invCV "OUT"))
					  )

				for(i 1 (pow 2 N)
					  bitID = (dbCreateParamInst pcCV dac_bitCV (sprintf nil "BIT%d" i) (0:0) "R0" 1
	   											 (list
	   											  (list "N" "int" N)
	   											  (list "W" "string" W)
	   											  (list "L" "string" L)
	   											  (list "R" "string" (sprintf nil "%f" Ra))))

					  if(i==1 then
							  netI=dbMakeNet(pcCV "Vlim")
							  else
							  netI=dbMakeNet(pcCV sprintf(nil "Vbit%d" i-1))
							  )
					  if(i==(pow 2 N) then
							netO=dbMakeNet(pcCV "gnd!")
							else
							netO=dbMakeNet(pcCV sprintf(nil "Vbit%d" i))
							)

	   				  select=""
	   				  for(j 0 N-1
	   						if(onep(bitfield1(i j))
	   							   select=strcat(select sprintf(nil "value<%d>," j+1))
	   							   select=strcat(select sprintf(nil "value_inv<%d>," j+1))))
					  select=substring(select 1 strlen(select)-1)
	   				  netBitSelect = dbMakeNet(pcCV select)

	   				  dbCreateInstTerm(netVout bitID dbFindTermByName(bitID~>master "Vselect"))
	   				  dbCreateInstTerm(netI bitID dbFindTermByName(bitID~>master "Vin"))
	   				  dbCreateInstTerm(netO bitID dbFindTermByName(bitID~>master "Vout"))
	   				  dbCreateInstTerm(netBitSelect bitID dbFindTermByName(bitID~>master sprintf(nil "select<%d:1>" N)))
					  )

				(dbClose dac_bitCV)
				(dbClose resCV)
				(dbClose invCV)

				t
				)
			  )

  (dbSave pcellId)
  (dbClose pcellId)
  )


(let (CellLibrary pcellId)
  CellLibrary = "sar_adc"
  unless( ddGetObj(CellLibrary)
				  error("Couldn't open library %L" CellLibrary)
				  )

  pcellId = (pcDefinePCell
			 list(ddGetObj(CellLibrary) "dac_test" "symbol" "schematicSymbol")
			 (
			  (N 1)
			  (W "240n")
			  (L "180n")
			  (Vlim "1.2")
			  (I "10u")
			  )

			 dbCreateRect(pcCellView
						  '("device" "drawing")
						  list(0.0:0.0 1.0:0.5))
			 dbCreateRect(pcCellView
						  '("instance" "drawing")
						  list(0.0:0.0 1.0:0.5))


			 (createPin pcCellView sprintf(nil "value<%d:1>" N) 0.0 0.250 0.25 "input" "centerLeft")
			 (createPin pcCellView "Vout" 1.0 0.250 -0.25 "output" "centerRight")


			 pcInst = dbCreateLabel(pcCellView '("instance" "label") 0:0.0 "[@instanceName]" "lowerLeft" "R0" "stick" 0.0625)
			 dbSetq(pcInst "NLPLabel" labelType)
			 pcInst = dbCreateLabel(pcCellView '("device" "label") 1.0:0 "[@cellName]" "lowerRight" "R0" "stick" 0.0625)
			 dbSetq(pcInst "NLPLabel" labelType)

			 t
			 )
  (dbSave pcellId)
  (dbClose pcellId)
  )
