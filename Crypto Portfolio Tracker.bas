Attribute VB_Name = "Module1"
Public Sub ActivateAllMacros()
Attribute ActivateAllMacros.VB_ProcData.VB_Invoke_Func = "r\n14"

'Store the current active cell and sheet first
Dim currentSheet As String
currentSheet = ActiveSheet.Name

'Call all the macros
Call CryptoCalculation
Call GenerateReport

'Save the workbook (Portfolio.xlsm) after updating
ActiveWorkbook.Save

'Go back to the original worksheet before the macro runs
'Sheets(currentSheet).Activate

'Activate report workbook
Workbooks("Report CAA " & Format(Date, "ddmmyy") & ".xlsx").Activate

End Sub
Public Sub CryptoCalculation()
Attribute CryptoCalculation.VB_ProcData.VB_Invoke_Func = " \n14"
Dim totalRows As Integer
Dim rowIndex As Integer
Dim counter As Integer
Dim totalPrice As Double
Dim totalQuantity As Double

'Get the total number of rows used in the Worksheet - Crypto
totalRows = Sheets("Crypto").Range("A" & Sheets("Crypto").Rows.Count).End(xlUp).Row

'Loop through each row and calculate the total price for each crypto
For rowIndex = 3 To totalRows

'Check if the crypto is the same as the next crypto (if different -> need to reset calculation)
If Sheets("Crypto").Range("A" & rowIndex).Value = Sheets("Crypto").Range("A" & rowIndex + 1).Value Then
totalPrice = totalPrice + Sheets("Crypto").Range("D" & rowIndex).Value
totalQuantity = totalQuantity + Sheets("Crypto").Range("B" & rowIndex).Value

Else
totalPrice = totalPrice + Sheets("Crypto").Range("D" & rowIndex).Value
totalQuantity = totalQuantity + Sheets("Crypto").Range("B" & rowIndex).Value

'Display the value in the sheet first
Sheets("Crypto").Range("g" & 3 + counter).Value = Sheets("Crypto").Range("A" & rowIndex).Value
Sheets("Crypto").Range("h" & 3 + counter).Value = totalQuantity
Sheets("Crypto").Range("i" & 3 + counter).Value = totalPrice
counter = counter + 1
totalPrice = 0
totalQuantity = 0

End If
Next rowIndex

End Sub
Public Sub GenerateReport()
Attribute GenerateReport.VB_ProcData.VB_Invoke_Func = " \n14"
Dim counter As Integer
Dim rowIndex As Integer
Dim totalRows As Integer
Dim totalValueIndex As Integer
Dim totalPLIndex As Integer
Dim totalETFRows As Integer
Dim user As String

Application.DisplayAlerts = False

'Create and activate new excel workbook
Workbooks.Add

'Create all the new sheets and delete the default sheet (sheet1)
Sheets.Add.Name = "Crypto Report"
Sheets("Sheet1").Delete

'Add the respective column headers
With Sheets("Crypto Report")
    .Range("A1").Value = "Name"
    .Range("B1").Value = "Total Quantity"
    .Range("C1").Value = "Total Price (BUSD)"
    .Range("D1").Value = "Average Price (BUSD)"
    .Range("E1").Value = "Average Price (SGD)"
    .Range("F1").Value = "Total Price (SGD)"
    .Range("G1").Value = "Percentage (%)"
End With


'Cut/Copy and paste the calculated values from the macro file into the new excel file
Workbooks("Crypto Portfolio.xlsm").Sheets("Crypto").Range("H3").CurrentRegion.Cut Destination:=Sheets("Crypto Report").Range("A2")



'Add formulas into cells for the respective columns
totalRows = Sheets("Crypto Report").Range("A" & Sheets("Crypto Report").Rows.Count).End(xlUp).Row
totalValueIndex = totalRows + 3
totalPLIndex = totalValueIndex + 1

For rowIndex = 2 To totalRows
With Sheets("Crypto Report")
    .Range("D" & rowIndex).Formula = "=C" & rowIndex & "/B" & rowIndex
    .Range("E" & rowIndex).Formula = "=D" & rowIndex & "*1.35"
    .Range("F" & rowIndex).Formula = "=C" & rowIndex & "*1.35"
End With
Next rowIndex




'Calculate total balance and value in SGD
With Sheets("Crypto Report")
    .Range("A" & totalValueIndex).Value = "Total SGD ($)"
    .Range("B" & totalValueIndex).Formula = "=Sum(F2:F" & totalRows & ")"
    .Range("A" & totalValueIndex).Font.Bold = True
    
    .Range("A" & totalPLIndex).Value = "Profit/Loss"
    .Range("B" & totalPLIndex).Formula = "=B" & totalValueIndex & "- Q1"
    .Range("A" & totalPLIndex).Font.Bold = True
    
    
End With

'Reset index counter and calculate the portfolio percentage for crypto
rowIndex = 0

For rowIndex = 2 To totalRows
Sheets("Crypto Report").Range("G" & rowIndex).Formula = "=F" & rowIndex & "/B" & totalValueIndex & "*100"
Next rowIndex

'Update and copy the necessary cells and worksheets in the macro file
With Workbooks("Crypto Portfolio.xlsm")
    .Sheets("Macro Instructions").Range("B1").Value = Date
    .Sheets("Macro Instructions").Range("C1").Value = Time
    
    '.Sheets("Overall Portfolio").Copy Sheets("Crypto Report")
    '.Sheets("NFT").Copy After:=Worksheets("Crypto Report")

    
    .Sheets("Crypto").Range("A1").CurrentRegion.Copy Destination:=Sheets("Crypto Report").Range("J1")
    .Sheets("Crypto").Range("G1").CurrentRegion.Copy Destination:=Sheets("Crypto Report").Range("P1")
    
End With

'Display and style the appropriate data values
With Sheets("Crypto Report")
    .UsedRange.Columns.AutoFit
    .Range("A1").EntireRow.Font.Bold = True
    .Columns(2).NumberFormat = "0.00"
    .Columns(3).NumberFormat = "0.00"
    .Columns(4).NumberFormat = "0.00000"
    .Columns(5).NumberFormat = "0.00"
    .Columns(6).NumberFormat = "0.00"
    .Columns(7).NumberFormat = "0.00"
    
End With


'Color the cell according to the profit/loss
If Sheets("Crypto Report").Range("B" & totalPLIndex).Value = 0 Then
    Sheets("Crypto Report").Range("B" & totalPLIndex).Interior.Color = xlNone

ElseIf Sheets("Crypto Report").Range("B" & totalPLIndex).Value > 0 Then
    Sheets("Crypto Report").Range("B" & totalPLIndex).Interior.Color = vbGreen

Else
    Sheets("Crypto Report").Range("B" & totalPLIndex).Interior.Color = vbRed
    
End If

'Remove all formulas in the Crypto Report worksheet
Sheets("Crypto Report").Activate
Cells.Range("A1").CurrentRegion.Copy
Cells.Range("A1").PasteSpecial xlPasteValues
Cells.Range("A1").AutoFilter
Cells.Range("A1").Select




'Save the workbook into a specified locaiton (or documents if unspecified)
user = Environ("userprofile")
Debug.Print user
ActiveWorkbook.SaveAs (user & "\Desktop\Report CAA " & Format(Date, "ddmmyy") & ".xlsx")

'Display Message Box
MsgBox "Report has been generated"

End Sub

Public Sub Red()
Attribute Red.VB_ProcData.VB_Invoke_Func = "q\n14"
Range(ActiveCell.Address).Interior.Color = vbRed
End Sub

Public Sub Blue()
Attribute Blue.VB_ProcData.VB_Invoke_Func = "e\n14"
Range(ActiveCell.Address).Interior.ColorIndex = 33
End Sub

Public Sub Green()
Attribute Green.VB_ProcData.VB_Invoke_Func = "w\n14"
Range(ActiveCell.Address).Interior.Color = vbGreen
End Sub
Public Sub ClearColor()
Attribute ClearColor.VB_ProcData.VB_Invoke_Func = "a\n14"
Range(ActiveCell.Address).Interior.Color = xlNone
End Sub

Public Sub Yellow()
Attribute Yellow.VB_ProcData.VB_Invoke_Func = "y\n14"
Range(ActiveCell.Address).Interior.Color = vbYellow
End Sub

Public Sub Purple()
Attribute Purple.VB_ProcData.VB_Invoke_Func = "n\n14"
Range(ActiveCell.Address).Interior.Color = vbMagenta
End Sub

