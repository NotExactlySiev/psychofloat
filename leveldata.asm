
        ; Level 1
LVL0:
        LEVEL_HEADER LVL1, 1, 4, 25
        BLK 3, 23, 4, 6
        BLK 18, 23, 7, 6
	BLK 5, 28, 15, 1
	FIL 0, 3
	FIL 1, 3
        SPK 8, 27, 0, 8
        HOK 12, 17, 0
        
LVL1:        
        LEVEL_HEADER LVL2, 0, 5, 5
        BLK 1, 28, 15, 1
        BLK 14, 28, 15, 1
        FIL 0, 4
        BLK 29, 14, 2, 15
        BLK 27, 23, 3, 1
        FIL 0, 0
        BLK 11, 25, 2, 1
        BLK 15, 19, 8, 1
        SPK 14, 27, 0, 10
        HOK 19, 17, 0
	BLK 15, 14, 3, 1
	BLK 16, 10, 1, 6
        FIL 0, 0
        BLK 1, 12, 1, 15
        BLK 1, 10, 7, 1
LVL2:
	.byte 0