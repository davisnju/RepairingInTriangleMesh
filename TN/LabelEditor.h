#pragma once


// CLabelEditor 对话框

class CLabelEditor : public CDialogEx
{
	DECLARE_DYNAMIC(CLabelEditor)

public:
    CLabelEditor(CWnd* pParent = NULL);   // 标准构造函数
	virtual ~CLabelEditor();

// 对话框数据
	enum { IDD = IDD_DIALOG_ADDlABELPROP };

protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV 支持

	DECLARE_MESSAGE_MAP()
public:
    CString m_PropName;
    CString m_PropValue;
    CString m_labelName;

    bool isNameChanged;
    bool isValueChanged;

    afx_msg void OnBnClickedOk();
    virtual BOOL OnInitDialog();
    afx_msg void OnChangeEditPname();
    afx_msg void OnEnChangeEditPvalue();
};
