page 50102 "Enter Year/Month"
{
    ApplicationArea = All;
    Caption = 'Enter Year/Month';
    PageType = List;
    SourceTable = "Date";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Period No."; Rec."Period No.")
                {
                    ToolTip = 'Specifies the number of the period shown in the line.';
                }
            }
        }
    }
}
page 50103 "Enter Day"
{
    ApplicationArea = All;
    Caption = 'Enter Day';
    PageType = List;
    SourceTable = "Date";
    UsageCategory = Lists;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Day; Date2DMY(Rec."Period Start", 1))
                {
                    ToolTip = 'Specifies the start date of the period shown in the line.';
                }
            }
        }
    }
}
tableextension 50118 CustomerExt extends Customer
{
    fields
    {
        field(50100; Year; Integer)
        {
            Caption = 'Year';
            DataClassification = CustomerContent;
            MinValue = 2000;
            MaxValue = 2099;
            trigger OnValidate()
            begin
                if Year <> 0 then begin
                    Month := 0;
                    Day := 0;
                    EnteredDate := 0D;
                end;
            end;
        }
        field(50101; Month; Integer)
        {
            Caption = 'Month';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 12;
            trigger OnValidate()
            begin
                if Year = 0 then
                    Error('Please enter a year first');
                if Month <> 0 then begin
                    Day := 0;
                    EnteredDate := 0D;
                end;
            end;
        }
        field(50102; Day; Integer)
        {
            Caption = 'Day';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 31;
            trigger OnValidate()
            begin
                if Month = 0 then
                    Error('Please enter a month first');
                if Day <> 0 then
                    EnteredDate := DMY2Date(Day, Month, Year);
            end;
        }
        field(50103; EnteredDate; Date)
        {
            Caption = 'Entered Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
pageextension 50118 CustomerListExt extends "Customer Card"
{
    layout
    {
        addafter(Name)
        {
            field(Year; Rec.Year)
            {
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    DateRec: Record Date;
                begin
                    DateRec.Reset();
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Year);
                    DateRec.SetRange("Period No.", 2000, 2099);
                    if Page.RunModal(Page::"Enter Year/Month", DateRec) = Action::LookupOK then
                        Rec.Validate(Year, DateRec."Period No.");
                end;
            }
            field(Month; Rec.Month)
            {
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    DateRec: Record Date;
                begin
                    if Rec.Year = 0 then
                        Error('Please enter a year first');
                    DateRec.Reset();
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Month);
                    DateRec.SetRange("Period Start", DMY2Date(1, 1, Rec.Year), DMY2Date(1, 12, Rec.Year));
                    if Page.RunModal(Page::"Enter Year/Month", DateRec) = Action::LookupOK then
                        Rec.Validate(Month, DateRec."Period No.");
                end;
            }
            field(Day; Rec.Day)
            {
                ApplicationArea = All;
                trigger OnLookup(var Text: Text): Boolean
                var
                    DateRec: Record Date;
                begin
                    if Rec.Month = 0 then
                        Error('Please enter a month first');
                    DateRec.Reset();
                    DateRec.SetRange("Period Type", DateRec."Period Type"::Date);
                    DateRec.SetRange("Period Start", DMY2Date(1, Rec.Month, Rec.Year), CalcDate('<CM>', DMY2Date(1, Rec.Month, Rec.Year)));
                    if Page.RunModal(Page::"Enter Day", DateRec) = Action::LookupOK then
                        Rec.Validate(Day, Date2DMY(DateRec."Period Start", 1));
                end;
            }
            field(EnteredDate; Rec.EnteredDate)
            {
                ApplicationArea = All;
            }
        }
    }
}
