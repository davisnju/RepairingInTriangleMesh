// LabelEditor.cpp : 实现文件
//

#include "stdafx.h"
#include "TNApp.h"
#include "LabelEditor.h"
#include "afxdialogex.h"


// CLabelEditor 对话框

IMPLEMENT_DYNAMIC(CLabelEditor, CDialogEx)

CLabelEditor::CLabelEditor(CWnd* pParent /*=NULL*/)
	: CDialogEx(CLabelEditor::IDD, pParent)
    , m_PropName(_T(""))
    , m_PropValue(_T(""))
{
    isNameChanged = false;
    isValueChanged = false;
}

CLabelEditor::~CLabelEditor()
{
}

void CLabelEditor::DoDataExchange(CDataExchange* pDX)
{
    CDialogEx::DoDataExchange(pDX);
    DDX_Text(pDX, IDC_EDIT_PNAME, m_PropName);
    DDV_MaxChars(pDX, m_PropName, 200);
    DDX_Text(pDX, IDC_EDIT_PVALUE, m_PropValue);
	DDV_MaxChars(pDX, m_PropValue, MAX_PROP_LEN);
}


BEGIN_MESSAGE_MAP(CLabelEditor, CDialogEx)
    ON_BN_CLICKED(IDOK, &CLabelEditor::OnBnClickedOk)
    ON_EN_CHANGE(IDC_EDIT_PNAME, &CLabelEditor::OnChangeEditPname)
    ON_EN_CHANGE(IDC_EDIT_PVALUE, &CLabelEditor::OnEnChangeEditPvalue)
END_MESSAGE_MAP()


// CLabelEditor 消息处理程序


void CLabelEditor::OnBnClickedOk()
{
    UpdateData(TRUE);
    if (m_PropName == L"")
    {
        AfxMessageBox(L"属性名称不能为空！");
        return;
    }
    CDialogEx::OnOK();
}


BOOL CLabelEditor::OnInitDialog()
{
    CDialogEx::OnInitDialog();

    SetWindowText(L"添加标签属性："+ m_labelName);

    return TRUE;  // return TRUE unless you set the focus to a control
    // 异常:  OCX 属性页应返回 FALSE
}


void CLabelEditor::OnChangeEditPname()
{
    isNameChanged = true;
}


void CLabelEditor::OnEnChangeEditPvalue()
{
    isValueChanged = true;
}
