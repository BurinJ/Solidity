addPlayer() - รับผู้เล่น 2 คนโดยแต่ละคนจ่าย 1 ether  
withdrawEarly() - ผู้เล่นจะสามารถถอนเงินออกได้หลังจากผู้เล่นได้ลงเงินไปก่อนอย่างน้อย 10 นาทีแล้วยังไม่มีผู้เล่นคนอื่นๆมา (require(minutesElapsed >= 10, "Timeout period not reached"))
และผู้เล่นจะสามารถถอนเงินออกได้หลังจากผู้เล่นคนแรกได้ลงเงินไปก่อนอย่างน้อย 10 นาทีแล้วเลือกอาวุธแล้วแต่อีกฝั่งยังไม่เลือกโดยจะรีเซ็ตระบบแล้วแบ่งเงินคืนให้ทั้ง 2 ฝ่าย
จากนั้นโปรแกรมจะ _resetGame()
input(uint dataHash) - ทำการเลือก choice เพื่อไม่ให้อีกฝั่งรู้โดย commit Hash(random string + choice string ['00' - Rock, '01' - Paper, '02' - Scissors, '03' - Lizard, '04' - Spock])
inputReveal(uint revealHash) - reveal choice หลังทั้ง 2 ฝ่ายเลือก choice แบบลับแล้วโดยแสดงค่าที่เมื่อนำไป Hash แล้วตรงกับที่แสดงลงใน input และระบบจะเก็บ choice จาก 8 บิตสุดท้ายแล้วนำไปตัดสินต่อที่ _checkWinnerAndPay()
_checkWinnerAndPay() - ตัดสินผู้ที่ชนะเกมด้วย _isWinner(uint choice0, uint choice1) และมอบรางวัลแล้ว _resetGame()
_isWinner(uint choice0, uint choice1) - ตัดสินผู้ที่ชนะเกม
_resetGame() - รีเซ็ตโปรแกรมให้กลับมาเล่นได้ใหม่
