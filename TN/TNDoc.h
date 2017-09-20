
// TNDoc.h : CTNDoc 类的接口
//


#pragma once

class CTNDoc : public CDocument
{
protected: // 仅从序列化创建
    CTNDoc();
    DECLARE_DYNCREATE(CTNDoc)

    // 特性
public:
    CString m_path; // 当前路径
    CString m_inipath;// 当前配置文件路径
    CString m_datapath; // 当前数据资源路径
    CList<CString> m_dataList;
    CString m_projname; // 当前项目名称,用来匹配标签属性文件

    // 
    int initModelZ;
    CString m_initModelName;
    CString workproj;
    // 操作
public:

    // 重写
public:
    virtual BOOL OnNewDocument();
    virtual void Serialize(CArchive& ar);
#ifdef SHARED_HANDLERS
    virtual void InitializeSearchContent();
    virtual void OnDrawThumbnail(CDC& dc, LPRECT lprcBounds);
#endif // SHARED_HANDLERS

    // 实现
public:
    virtual ~CTNDoc();
#ifdef _DEBUG
    virtual void AssertValid() const;
    virtual void Dump(CDumpContext& dc) const;
#endif

protected:

    // 生成的消息映射函数
protected:
    DECLARE_MESSAGE_MAP()

#ifdef SHARED_HANDLERS
    // 用于为搜索处理程序设置搜索内容的 Helper 函数
    void SetSearchContent(const CString& value);
#endif // SHARED_HANDLERS
public:
    afx_msg void OnSceneSave();
    afx_msg void OnFileOpen();
    afx_msg void OnFileSave();
    afx_msg void OnFileSaveAs();
    virtual void OnCloseDocument();
};
