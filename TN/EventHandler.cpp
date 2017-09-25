#include "stdafx.h"
#include <osgParticle/FireEffect>
#include <osg/ShapeDrawable>
#include <osg/PositionAttitudeTransform>
#include <osg/Texture2D>

#include "EventHandler.h"
#include "TNApp.h"
#include "MainFrm.h"
#include "TNDoc.h"
#include "findNodeVisitor.h"

#include "Utility.h"


//获取整数a位数
int getNumLength(int a)
{
    int k = 0;
    while (a)
    {
        a = a / 10;
        k++;
    }
    return k;
}

bool CEventHandler::handle(const osgGA::GUIEventAdapter &ea, osgGA::GUIActionAdapter &aa)
{

    // 获取鼠标位置  
    float mouseX = ea.getX();
    float mouseY = ea.getY();
    osgViewer::Viewer* viewer = dynamic_cast<osgViewer::Viewer*>(&aa);
    switch (ea.getEventType())
    {
    case  osgGA::GUIEventAdapter::KEYDOWN:
        // 按下Return
        if (ea.getKey() == osgGA::GUIEventAdapter::KEY_Return)
        {
             // 清除dragger
			 //if (draggerGroupIdx > 0 && (mModelRotating || mModelTransfering || mModelScaling))
			 //{
				 //return removeDragger(viewer);
			 //}
             if (draggerGroupIdx > 0 && mModelRotating)
             {
                 //return removeTrackballDragger(viewer);
				 return removeDragger(viewer);
             }
             if (draggerGroupIdx > 0 && mModelTransfering)
             {
                 //return removeTabDragger(viewer);
				 return removeDragger(viewer);
             }
			 if (draggerGroupIdx > 0 && mModelScaling)
			 {
				 //return removeScaleDragger(viewer);
				 return removeDragger(viewer);
			 }
             return true;
        }
        else if (ea.getKey() == osgGA::GUIEventAdapter::KEY_Q)
        {
            return cancelDragger(viewer);
        }
        return false;
    case osgGA::GUIEventAdapter::PUSH:
        if (ea.getButton() == 1)
        { // 1 表示按鼠标左键

            m_bLeftButtonDown = true;
            m_fpushX = mouseX;
            m_fpushY = mouseY;

            if (mModelRotate && !mModelRotating)
            {
                return rotateSelected(viewer, ea);
            }
            else if (mModelTrans && !mModelTransfering)
            {
                return transferSelected(viewer, ea);
            }
			else if (mModelScale && !mModelScaling)
			{
				return scaleSelected(viewer, ea);
			}
			else if (mModelRotate && mModelRotating){
				Group* root = dynamic_cast<Group*>(viewer->getSceneData());
				Node* selectedModel = root;

				osgUtil::LineSegmentIntersector::Intersections intersections;
				if (viewer->computeIntersections(ea, intersections))
				{
					const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();
					const NodePath& nodePath = hit.nodePath;
					for (NodePath::const_iterator nitr = nodePath.begin();
						nitr != nodePath.end();
						++nitr)
					{
						const Group* cube = dynamic_cast<const Group*>(*nitr);
						if (cube)
						{
							if (cube->getName() == "Dragger")
							{
								if (cube == m_draggerGroup)
									return 0;
							}
						}
					}
				}
				removeDragger(viewer);
				return rotateSelected(viewer, ea);
			}
			else if (mModelTrans && mModelTransfering){
				Group* root = dynamic_cast<Group*>(viewer->getSceneData());
				Node* selectedModel = root;

				osgUtil::LineSegmentIntersector::Intersections intersections;
				if (viewer->computeIntersections(ea, intersections))
				{
					const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();
					const NodePath& nodePath = hit.nodePath;
					for (NodePath::const_iterator nitr = nodePath.begin();
						nitr != nodePath.end();
						++nitr)
					{
						const Group* cube = dynamic_cast<const Group*>(*nitr);
						if (cube)
						{
							if (cube->getName() == "Dragger")
							{
								if (cube == m_tabDraggerGroup)
									return 0;
							}
						}
					}
				}
				removeDragger(viewer);
				return transferSelected(viewer, ea);
			}
			else if (mModelScale && mModelScaling){
				Group* root = dynamic_cast<Group*>(viewer->getSceneData());
				Node* selectedModel = root;

				osgUtil::LineSegmentIntersector::Intersections intersections;
				if (viewer->computeIntersections(ea, intersections))
				{
					const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();
					const NodePath& nodePath = hit.nodePath;
					for (NodePath::const_iterator nitr = nodePath.begin();
						nitr != nodePath.end();
						++nitr)
					{
						const Group* cube = dynamic_cast<const Group*>(*nitr);
						if (cube)
						{
							if (cube->getName() == "Dragger")
							{
								if (cube == m_scaleDraggerGroup)
									return 0;
							}
						}
					}
				}
				removeDragger(viewer);
				return scaleSelected(viewer, ea);
			}

        }
        return false;
        // 鼠标释放  
    case(osgGA::GUIEventAdapter::RELEASE) :
        if (ea.getButton() == 1)
        {
            m_bLeftButtonDown = false;
            if (addFireValid) return addFire(viewer, ea);
        }
        if (ea.getButton() == 4)  //4 表示按鼠标右键  
        {
            if (addModelValid) return addModel(viewer, ea);
            if (addLabelValid) return addLabel(viewer, ea);

            if (_rectify_H)
            {
                RectifyH(viewer, ea);
            }
        }
    }
    return false;
}

bool CEventHandler::addFire(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter& ea)
{
    if (!addFireValid)
        return false;

    Group* root = dynamic_cast<Group*>(viewer->getSceneData());
    if (!root) return false;

    osgUtil::LineSegmentIntersector::Intersections intersections;
    if (viewer->computeIntersections(ea, intersections))
    {
        const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();

        bool handleMovingModels = false;
        const NodePath& nodePath = hit.nodePath;
        for (NodePath::const_iterator nitr = nodePath.begin();
             nitr != nodePath.end();
             ++nitr)
        {
            std::cout << "NodePath Node " << (*nitr)->getName() << std::endl;
            const MatrixTransform* cube = dynamic_cast<const MatrixTransform*>(*nitr);
            if (cube)
            {
                if (cube->getName() == "Matrix") handleMovingModels = true;
            }
        }

        Vec3 positionfire = handleMovingModels ? hit.getLocalIntersectPoint() : hit.getWorldIntersectPoint();
        float scale = 1.0f * ((float)rand() / (float)RAND_MAX);
        if (m_firescale > 0.0f)
        {
            scale = m_firescale;
        }
        float intensity = 1.0f;
        osgParticle::FireEffect* fire = new osgParticle::FireEffect(positionfire, scale, intensity);
        Vec3 wind(0.0f, 0.0f, -1.0f);
        fire->setWind(wind);
        Group* effectsGroup = new Group;
        effectsGroup->addChild(fire);
        effectsGroup->setName("Fire");

        if (handleMovingModels)
        {
            fire->setUseLocalParticleSystem(false);

            ref_ptr<Node> hitNode = hit.nodePath.back();
            Node::ParentList parents = hitNode->getParents();
            Group* insertGroup = 0;
            unsigned int numGroupsFound = 0;
            for (Node::ParentList::iterator itr = parents.begin();
                 itr != parents.end();
                 ++itr)
            {
                Group* parent = (*itr);
                if (typeid(*parent) == typeid(Group))
                {
                    ++numGroupsFound;
                    insertGroup = parent;
                }
            }
            if (numGroupsFound == parents.size() && numGroupsFound == 1 && insertGroup)
            {
                // just reuse the existing group.
                insertGroup->addChild(effectsGroup);
            }
            else
            {
                insertGroup = new Group;
                for (Node::ParentList::iterator itr = parents.begin();
                     itr != parents.end();
                     ++itr)
                {
                    (*itr)->replaceChild(hit.nodePath.back(), insertGroup);
                }
                insertGroup->addChild(hitNode.get());
                insertGroup->addChild(effectsGroup);
            }

            Geode* geode = new Geode;
            geode->addDrawable(fire->getParticleSystem());

            root->addChild(geode);

            return true;
        }
        else
        {

        }
    }
    return false;
}

bool CEventHandler::addModel(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter& ea)
{
    if (!addModelValid)
        return false;

    CString modelstr, modelname = m_modelname.Left(m_modelname.ReverseFind('.')), rawModelStr = m_modelname;
    modelstr = rawModelStr;
    // 消除重名node
    CTNApp *app = (CTNApp *)AfxGetApp();
    std::set<CString> nodeNameSet = app->nodeNameSet;
    CString istr;
    int num = 0;
    while (nodeNameSet.find(modelstr) != nodeNameSet.end())
    {
        if (num > 0)
            modelname = modelname.Left(modelname.GetLength() - getNumLength(num));
        num++;
        istr.Format(_T("%d"), num);
        modelname += istr;
        modelstr = modelname + L".osg";
    }

    Group* root = dynamic_cast<Group*>(viewer->getSceneData());
    if (!root) return false;
    osgUtil::LineSegmentIntersector::Intersections intersections;
    if (viewer)
    {
        if (viewer->computeIntersections(ea, intersections))
        {
            const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();
            Vec3 position = hit.getWorldIntersectPoint();
            Vec3 positionlocal = hit.getLocalIntersectPoint();
            CString cstr;
            cstr.Format(_T("world: %.1f, %.1f, %.1f\nlocal: %.1f, %.1f, %.1f\n")
                        , position.x(), position.y(), position.z()
                        , positionlocal.x(), positionlocal.y(), positionlocal.z());
            cstr += modelstr;

            bool handleMovingModels = false;
            const NodePath& nodePath = hit.nodePath;
            for (NodePath::const_iterator nitr = nodePath.begin();
                 nitr != nodePath.end();
                 ++nitr)
            {
                std::cout << "NodePath Node " << (*nitr)->getName() << std::endl;
                const MatrixTransform* cube = dynamic_cast<const MatrixTransform*>(*nitr);
                if (cube)
                {
                    if (cube->getName() == "BASE") handleMovingModels = true;
                }
            }

            if (handleMovingModels)
            {
                std::cout << "handleMovingModels" << std::endl;
            }
            else
            {
                std::cout << "base" << std::endl;
            }

            Node* newNode = osgDB::readNodeFile(
                CStringA(rawModelStr).GetBuffer(0));
            if (newNode ==  NULL)
            {
                AfxMessageBox(rawModelStr + L"模型文件读取失败！");
                return false;
            }
            newNode->setName(CStringA(modelstr).GetBuffer(0));
            MatrixTransform* trans = new MatrixTransform;
            trans->setName("Matrix");
            float r = newNode->getBound().radius();
            float z = newNode->getBound().center().z() - r;
            Vec3f positionAdj = position*Matrix::translate(Vec3f(0, 0, -z / 2)); // adjust zxis position

            // Sphere
            ref_ptr<Geode> unitSphere = new Geode;
            ref_ptr<Sphere> sphere = new Sphere(newNode->getBound().center(), r);
            ref_ptr<ShapeDrawable> shapeDrawable = new ShapeDrawable(sphere.get());
            unitSphere->addDrawable(shapeDrawable.get());
            //ref_ptr<PositionAttitudeTransform> sphereForm = new PositionAttitudeTransform;
            //sphereForm->setPosition(Vec3(2.5, 0.0, 0.0));
            //sphereForm->addChild(unitSphere.get());

            cstr.Format(_T("%.1f, %.1f, %.1f\n%.1f, %.1f, %.1f\n"),
                        position.x(), position.y(), position.z()
                        , positionAdj.x(), positionAdj.y(), positionAdj.z()
                        );
            //AfxMessageBox(cstr.GetBuffer());

            trans->setMatrix(Matrix::scale(m_modelsize, m_modelsize, m_modelsize) // adjust scale
                             *Matrix::translate(positionAdj) // adjust position
                             );
            trans->addChild(newNode);
            //trans->addChild(unitSphere);
            Group* newGroup = new Group;
            newGroup->addChild(trans);
            string new_node_name = WChar2Ansi(m_nodename.GetBuffer(m_nodename.GetLength()));
            newGroup->setName(new_node_name);
            // m_Root->addChild(newNode.get());
            if (root)
            {

                // 添加模型到根节点
                root->addChild(newGroup);
                                
                // 发送消息 更新节点视图
                HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
                CString cstr;
                cstr = newNode->getName().c_str();
                app->insertNodeName2(cstr);    //  debugging
                SendMessage(hMainWnd, WM_USER_ADDMODELNAME,
                            NULL, (LPARAM)cstr.GetBuffer(cstr.GetAllocLength()));

            }
            else
            {
                AfxMessageBox(_T("root is null"));
            }
        }
        else
        {
            AfxMessageBox(_T("no Intersections"));
        }
    }
    else
    {
        AfxMessageBox(_T("view is null"));
    }
    return false;
}

bool CEventHandler::rotateSelected(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea)
{
    if (!mModelRotate)
        return false;

    Group* root = dynamic_cast<Group*>(viewer->getSceneData());
    if (!root) return false;

    Node* selectedModel = root;

    osgUtil::LineSegmentIntersector::Intersections intersections;
    if (viewer->computeIntersections(ea, intersections))
    {
        const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();

        bool handleMovingModels = false;
        const NodePath& nodePath = hit.nodePath;
        for (NodePath::const_iterator nitr = nodePath.begin();
             nitr != nodePath.end();
             ++nitr)
        {
            //std::cout << "NodePath Node " << (*nitr)->getName() << std::endl;
            const Group* cube = dynamic_cast<const Group*>(*nitr);
            if (cube)
            {
                //CString cstr;
                //cstr = cube->getName().c_str();

                //AfxMessageBox(cstr.GetBuffer());
                if (cube->getName() == "Model"
                    || cube->getName() == "Label")
                {
                    handleMovingModels = true;
                    selectedModel = (*nitr);
                }
            }
        }

        //selection
        osgManipulator::Selection* selection = new osgManipulator::Selection;

        if (handleMovingModels)
        {
            ref_ptr<Node> hitNode = selectedModel; // hit.nodePath.back();
            Node::ParentList parents = hitNode->getParents();
            Group* insertGroup = 0;
            unsigned int numGroupsFound = 0;
            for (Node::ParentList::iterator itr = parents.begin();
                 itr != parents.end();
                 ++itr)
            {
                Group* parent = (*itr);
                if (typeid(*parent) == typeid(Group))
                {
                    ++numGroupsFound;
                    insertGroup = parent;
                }
            }
            if (numGroupsFound == parents.size() && numGroupsFound == 1 && insertGroup)
            {
                // 一般情况都是单父节点
                // AfxMessageBox(_T("single"));
                // 选当前节点selectedModel和其父节点insertGroup
                selection->addChild(selectedModel);//将需要操控的场景对象添加到Selection下  
                float scale = selectedModel->getBound().radius()*1.6;//Dragger的大小是依照物体的外包围球来计算，获取半径，然后稍微放大一点，在将这个值传给Dragger,
                ////设置TrackballDragger  
                osgManipulator::TrackballDragger* dragger = new osgManipulator::TrackballDragger();
                dragger->setupDefaultGeometry();
                dragger->setMatrix(Matrix::scale(scale*0.5, scale*0.5, scale*0.5)
                                   *Matrix::translate(selectedModel->getBound().center()));
                dragger->addTransformUpdating(selection);
                dragger->setHandleEvents(true);
                //设置了这个dragger的启动热键，当前为Ctrl，当按住Ctrl时，单击圆环，方能旋转。 
                dragger->setActivationModKeyMask(osgGA::GUIEventAdapter::MODKEY_CTRL);

                if (root == insertGroup)
                {
                    Group* draggerGroup = new Group();
                    draggerGroup->setName("Dragger");
                    draggerGroup->addChild(selection);
                    draggerGroup->addChild(dragger);
                    root->addChild(draggerGroup);
                    root->removeChild(
                        root->getChildIndex(selectedModel));
                    mModelRotating = true;
                    m_draggerGroup = draggerGroup;
                    draggerGroupIdx = root->getChildIndex(draggerGroup);
                }
                return true;
            }
            else
            {
                insertGroup = new Group;
                for (Node::ParentList::iterator itr = parents.begin();
                     itr != parents.end();
                     ++itr)
                {
                    (*itr)->replaceChild(hit.nodePath.back(), insertGroup);
                }
                insertGroup->addChild(hitNode.get());

                //AfxMessageBox(_T("multiple"));
                // 选最后一个父节点insertGroup 
            }

            return true;
        }
        else
        {
            //AfxMessageBox(_T("no model selected"));
        }
    }
    return false;
}

bool CEventHandler::transferSelected(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea)
{
    if (!mModelTrans)
        return false;

    // 发送消息 更新调试信息
    //HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();

    //CString  cstr("test");
    //SendMessage(hMainWnd, WM_USER_THREADEND,
    //WPARAM(cstr.GetAllocLength()), (LPARAM)cstr.GetBuffer(cstr.GetAllocLength()));


    Group* root = dynamic_cast<Group*>(viewer->getSceneData());
    if (!root) return false;

    Node* selectedModel = root;

    osgUtil::LineSegmentIntersector::Intersections intersections;
    if (viewer->computeIntersections(ea, intersections))
    {
        const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();

        bool handleMovingModels = false;
        const NodePath& nodePath = hit.nodePath;
        for (NodePath::const_iterator nitr = nodePath.begin();
             nitr != nodePath.end();
             ++nitr)
        {
            std::cout << "NodePath Node " << (*nitr)->getName() << std::endl;
            const Group* cube = dynamic_cast<const Group*>(*nitr);
            if (cube)
            {
                if (cube->getName() == "Model"
                    || cube->getName() == "Label")
                {
                    handleMovingModels = true;
                    selectedModel = (*nitr);
                }
            }
        }

        //selection
        osgManipulator::Selection* selection = new osgManipulator::Selection;

        if (handleMovingModels)
        {
            ref_ptr<Node> hitNode = selectedModel;// hit.nodePath.back();
            Node::ParentList parents = hitNode->getParents();
            Group* insertGroup = 0;
            unsigned int numGroupsFound = 0;
            for (Node::ParentList::iterator itr = parents.begin();
                 itr != parents.end();
                 ++itr)
            {
                //if (*itr == root){
                //AfxMessageBox(_T("*itr == root"));
                //}
                Group* parent = (*itr);
                if (typeid(*parent) == typeid(Group))
                {
                    ++numGroupsFound;
                    insertGroup = parent;
                    //if (insertGroup == root){
                    //AfxMessageBox(_T("insertGroup == root"));
                    //}
                }
            }
            if (numGroupsFound == parents.size() && numGroupsFound == 1 && insertGroup)
            {

                // just reuse the existing group.
                // AfxMessageBox(_T("single"));
                // 选当前节点selectedModel和其父节点insertGroup
                selection->addChild(selectedModel);//将需要操控的场景对象添加到Selection下  
                float scale = selectedModel->getBound().radius()*1.6;//Dragger的大小是依照物体的外包围球来计算，获取半径，然后稍微放大一点，在将这个值传给Dragger,
                ////设置TabBoxDragger
                //osgManipulator::TabBoxDragger* tabDragger = new osgManipulator::TabBoxDragger();
				osgManipulator::TranslateAxisDragger* tabDragger = new osgManipulator::TranslateAxisDragger;
				tabDragger->setupDefaultGeometry();
                tabDragger->setMatrix(Matrix::scale(scale, scale, scale)
                                      *Matrix::translate(selectedModel->getBound().center()));
                tabDragger->addTransformUpdating(selection);
                tabDragger->setHandleEvents(true);
                //设置了这个dragger的启动热键，当前为Ctrl，当按住Ctrl时，单击圆环，方能旋转。 
                tabDragger->setActivationModKeyMask(osgGA::GUIEventAdapter::MODKEY_CTRL);

                if (root == insertGroup)
                {
                    Group* tabDraggerGroup = new Group();
                    tabDraggerGroup->setName("Dragger");
                    tabDraggerGroup->addChild(selection);
                    tabDraggerGroup->addChild(tabDragger);
                    root->addChild(tabDraggerGroup);
                    root->removeChild(
                        root->getChildIndex(selectedModel));
                    mModelTransfering = true;
                    draggerGroupIdx = root->getChildIndex(tabDraggerGroup);
                    m_tabDraggerGroup = tabDraggerGroup;
                }
            }
            else
            {
                insertGroup = new Group;
                for (Node::ParentList::iterator itr = parents.begin();
                     itr != parents.end();
                     ++itr)
                {
                    (*itr)->replaceChild(hit.nodePath.back(), insertGroup);
                }
                insertGroup->addChild(hitNode.get());

                //AfxMessageBox(_T("cacaca"));
                //insertGroup->addChild(effectsGroup);
            }

            return true;
        }
        else
        {
            //AfxMessageBox(_T("no model selected1"));
        }
    }
    return false;
}

bool CEventHandler::scaleSelected(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea)
{
	if (!mModelScale)
		return false;

	Group* root = dynamic_cast<Group*>(viewer->getSceneData());
	if (!root) return false;

	Node* selectedModel = root;

	osgUtil::LineSegmentIntersector::Intersections intersections;
	if (viewer->computeIntersections(ea, intersections))
	{
		const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();

		bool handleMovingModels = false;
		const NodePath& nodePath = hit.nodePath;
		for (NodePath::const_iterator nitr = nodePath.begin();
			nitr != nodePath.end();
			++nitr)
		{
			//std::cout << "NodePath Node " << (*nitr)->getName() << std::endl;
			const Group* cube = dynamic_cast<const Group*>(*nitr);
			if (cube)
			{
                if (cube->getName() == "Model"
                    || cube->getName() == "Label")
				{
					handleMovingModels = true;
					selectedModel = (*nitr);
				}
			}
		}

		//selection
		osgManipulator::Selection* selection = new osgManipulator::Selection;

		if (handleMovingModels)
		{
			ref_ptr<Node> hitNode = selectedModel;// hit.nodePath.back();
			Node::ParentList parents = hitNode->getParents();
			Group* insertGroup = 0;
			unsigned int numGroupsFound = 0;
			for (Node::ParentList::iterator itr = parents.begin();
				itr != parents.end();
				++itr)
			{
				Group* parent = (*itr);
				if (typeid(*parent) == typeid(Group))
				{
					++numGroupsFound;
					insertGroup = parent;
					//if (insertGroup == root){
					//AfxMessageBox(_T("insertGroup == root"));
					//}
				}
			}
			if (numGroupsFound == parents.size() && numGroupsFound == 1 && insertGroup)
			{

				// just reuse the existing group.
				// AfxMessageBox(_T("single"));
				// 选当前节点selectedModel和其父节点insertGroup
				selection->addChild(selectedModel);//将需要操控的场景对象添加到Selection下  
				float scale = selectedModel->getBound().radius()*1.6;//Dragger的大小是依照物体的外包围球来计算，获取半径，然后稍微放大一点，在将这个值传给Dragger,
				////设置TabBoxDragger
				//osgManipulator::TabBoxDragger* tabDragger = new osgManipulator::TabBoxDragger();
				osgManipulator::ScaleAxisDragger* scaleDragger = new osgManipulator::ScaleAxisDragger;
				scaleDragger->setupDefaultGeometry();
				scaleDragger->setMatrix(Matrix::scale(scale, scale, scale)
					*Matrix::translate(selectedModel->getBound().center()));
				scaleDragger->addTransformUpdating(selection);
				scaleDragger->setHandleEvents(true);
				//设置了这个dragger的启动热键，当前为Ctrl，当按住Ctrl时，单击圆环，方能旋转。 
				scaleDragger->setActivationModKeyMask(osgGA::GUIEventAdapter::MODKEY_CTRL);

				if (root == insertGroup)
				{
					Group* scaleDraggerGroup = new Group();
					scaleDraggerGroup->setName("Dragger");
					scaleDraggerGroup->addChild(selection);
					scaleDraggerGroup->addChild(scaleDragger);
					root->addChild(scaleDraggerGroup);
					root->removeChild(
						root->getChildIndex(selectedModel));
					mModelScaling = true;
					draggerGroupIdx = root->getChildIndex(scaleDraggerGroup);
					m_scaleDraggerGroup = scaleDraggerGroup;
				}
			}
			else
			{
				insertGroup = new Group;
				for (Node::ParentList::iterator itr = parents.begin();
					itr != parents.end();
					++itr)
				{
					(*itr)->replaceChild(hit.nodePath.back(), insertGroup);
				}
				insertGroup->addChild(hitNode.get());

				//AfxMessageBox(_T("cacaca"));
				//insertGroup->addChild(effectsGroup);
			}

			return true;
		}
		else
		{
			//AfxMessageBox(_T("no model selected1"));
		}
	}
	return false;
}

bool CEventHandler::removeDragger(osgViewer::Viewer* viewer)
{
	Group* root = dynamic_cast<Group*>(viewer->getSceneData());
	if (!root) return false;
	bool existDragger = false;
	int rootChildNum = root->getNumChildren();
	for (int i = 0; i < rootChildNum; i++)
	{
		Group* dg = dynamic_cast<Group*>(root->getChild(i));
		if (dg->getName() == "Dragger")
		{
			existDragger = true;
			draggerGroupIdx = i;
			break;
		}
	}
	if (existDragger && (m_draggerGroup != NULL || m_tabDraggerGroup != NULL || m_scaleDraggerGroup != NULL))
	{
		Group* dg = dynamic_cast<Group*>(root->getChild(draggerGroupIdx));
		osgManipulator::Selection* selection = dynamic_cast<osgManipulator::Selection*>(dg->getChild(0));
		//osgManipulator::ScaleAxisDragger* tbd = dynamic_cast<osgManipulator::ScaleAxisDragger*>(dg->getChild(1));
		//Node* selectedModel = selection->getChild(0);
		Group* selectedModel = selection->getChild(0)->asGroup();
		if (selectedModel)
		{
			MatrixTransform* mt = dynamic_cast<MatrixTransform*>(selectedModel->getChild(0));
			Node* node = mt->getChild(0);


			MatrixTransform* trans = new MatrixTransform;
			trans->setMatrix(mt->getMatrix() * Matrix::scale(selection->getMatrix().getScale()) 
                             * Matrix::rotate(selection->getMatrix().getRotate()) 
                             * Matrix::translate(selection->getMatrix().getTrans()));
			trans->setName("Matrix");

			//Matrix::scale(selection->getMatrix.getScale());
			trans->addChild(node);
			Group* newGroup = new Group;
			newGroup->addChild(trans);
			newGroup->setName("Model");

			//sendBuildString(_T("remove dragger"));


			root->addChild(newGroup);

			root->removeChild(root->getChildIndex(m_draggerGroup));
			root->removeChild(root->getChildIndex(m_tabDraggerGroup));
			root->removeChild(root->getChildIndex(m_scaleDraggerGroup));
			m_tabDraggerGroup = NULL;
			m_draggerGroup = NULL;
			m_scaleDraggerGroup = NULL;
			mModelRotating = false;
			mModelTransfering = false;
			mModelScaling = false;
			draggerGroupIdx = -1;
		}
	}
	return false;
}

bool CEventHandler::cancelDragger(osgViewer::Viewer* viewer)
{
	Group* root = dynamic_cast<Group*>(viewer->getSceneData());
	if (!root) return false;

	bool existDragger = false;
	int rootChildNum = root->getNumChildren();
	for (int i = 0; i < rootChildNum; i++)
	{
		Group* dg = dynamic_cast<Group*>(root->getChild(i));
		if (dg->getName() == "Dragger" || dg->getName() == "tabDragger" || dg->getName() == "scaleDragger")
		{
			existDragger = true;
			draggerGroupIdx = i;
			break;
		}
	}
	if (existDragger && (m_draggerGroup != NULL || m_tabDraggerGroup != NULL || m_scaleDraggerGroup != NULL))
	{
		Group* dg = dynamic_cast<Group*>(root->getChild(draggerGroupIdx));
		osgManipulator::Selection* selection = dynamic_cast<osgManipulator::Selection*>(dg->getChild(0));

		Group* selectedModel = selection->getChild(0)->asGroup();
		if (selectedModel)
		{
			// Matrix::rotate(td->getMatrix().getRotate())  
			MatrixTransform* mt =
				dynamic_cast<MatrixTransform*>(selectedModel->getChild(0));
			Node * node = mt->getChild(0);

			CString cstr;
			cstr = mt->getName().c_str();
			cstr = node->getName().c_str();

			Group* newGroup = new Group;
			newGroup->addChild(mt);
			newGroup->setName("Model");

			//AfxMessageBox(_T("remove dragger"));
			root->addChild(newGroup);
			root->removeChild(root->getChildIndex(m_draggerGroup));
			root->removeChild(root->getChildIndex(m_tabDraggerGroup));
			root->removeChild(root->getChildIndex(m_scaleDraggerGroup));
			m_tabDraggerGroup = NULL;
			m_draggerGroup = NULL;
			m_scaleDraggerGroup = NULL;
			mModelRotating = false;
			mModelTransfering = false;
			mModelScaling = false;
			draggerGroupIdx = -1;
		}
	}
	return false;
}

bool CEventHandler::addLabel(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea)
{
    
    if (!addLabelValid)
        return false;

    Group* root = dynamic_cast<Group*>(viewer->getSceneData());
    if (!root) return false;

    osgUtil::LineSegmentIntersector::Intersections intersections;
    if (viewer->computeIntersections(ea, intersections))
    {
        const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();

        bool handleMovingModels = false;
        const NodePath& nodePath = hit.nodePath;
        for (NodePath::const_iterator nitr = nodePath.begin();
             nitr != nodePath.end();
             ++nitr)
        {
            std::cout << "NodePath Node " << (*nitr)->getName() << std::endl;
            const MatrixTransform* cube = dynamic_cast<const MatrixTransform*>(*nitr);
            if (cube)
            {
                if (cube->getName() == "Matrix") handleMovingModels = true;
            }
        }

        Vec3 positionLabel = handleMovingModels ? hit.getLocalIntersectPoint() : hit.getWorldIntersectPoint();
        
        ref_ptr<Node> labelNode = creatLabel();
        MatrixTransform* trans = new MatrixTransform;
        trans->setName("Matrix");
        float r = labelNode->getBound().radius();
        float z = labelNode->getBound().center().z() - r;
        Vec3f positionAdj = hit.getWorldIntersectPoint()
            *Matrix::translate(Vec3f(0, 0, - z / 2)); // adjust zxis position
        trans->setMatrix(Matrix::translate(positionAdj));
        trans->addChild(labelNode);
        //trans->addChild(unitSphere);
        Group* labelGroup = new Group;
        labelGroup->addChild(trans);
        labelGroup->setName("Label");

        if (handleMovingModels)
        {
            ref_ptr<Node> hitNode = hit.nodePath.back();
            Node::ParentList parents = hitNode->getParents();
            Group* insertGroup = 0;
            unsigned int numGroupsFound = 0;
            for (Node::ParentList::iterator itr = parents.begin();
                 itr != parents.end();
                 ++itr)
            {
                Group* parent = (*itr);
                if (typeid(*parent) == typeid(Group))
                {
                    ++numGroupsFound;
                    insertGroup = parent;
                }
            }
            if (numGroupsFound == parents.size() && numGroupsFound == 1 && insertGroup)
            {
                // just reuse the existing group.
                // insertGroup->addChild(labelGroup);
            }
            else
            {
                insertGroup = new Group;
                for (Node::ParentList::iterator itr = parents.begin();
                     itr != parents.end();
                     ++itr)
                {
                    (*itr)->replaceChild(hit.nodePath.back(), insertGroup);
                }
                insertGroup->addChild(hitNode.get());
                //insertGroup->addChild(labelGroup);

            }

            root->addChild(labelGroup);

            CString pName, cName;
            pName = insertGroup->getName().c_str();
            cName = labelNode->getName().c_str();
            CTNApp *app = (CTNApp *)AfxGetApp();
            app->insertNodeName2(cName);    //  debugging
            HWND hMainWnd = AfxGetApp()->GetMainWnd()->GetSafeHwnd();
            // 发送消息 更新调试信息
            SendMessage(hMainWnd, WM_USER_ADDMODELNAME,
                        WPARAM(cName.GetBuffer(cName.GetAllocLength()))
                        , (LPARAM)pName.GetBuffer(pName.GetAllocLength()));

            /*Geode* geode = new Geode;
            root->addChild(geode);*/

            return true;
        }
        else
        {

        }
    }
    return false;
}

ref_ptr<Node> CEventHandler::creatLabel()
{
    ref_ptr<Cone>  cone = new Cone;
    ref_ptr<ShapeDrawable> shap = new ShapeDrawable(cone);
    ref_ptr<Geode> geode = new Geode;
    geode->addDrawable(shap);
    ////光照模式关闭，这样从各个方向看到的图片才是一样的  
    geode->getOrCreateStateSet()->setMode(GL_LIGHTING, StateAttribute::OFF);
    //设置圆锥高  
    cone->setHeight(0.6);
    //设置圆锥地面半径  
    cone->setRadius(0.3);

    //设置圆锥的颜色，第四个参数0.25表示不透明度，0表示完全透明，1表示完全不透明  
    shap->setColor(Vec4(1.0, 0.0, 0.0, 1));

    Quat quat;
    //根据两个向量计算四元数  
    quat.makeRotate(Z_AXIS, Vec3(0.0, 0.0, -1.0));
    cone->setRotation(quat);
    ref_ptr<Group> group = new Group;
    // 查重名Label，修改新加的Label名，确保无重名Label
    CTNApp *app = (CTNApp *)AfxGetApp();
    std::set<CString> nodeNameSet = app->nodeNameSet;
    CString istr, modelstr("Label0");
    int num = 0;
    while (nodeNameSet.find(modelstr) != nodeNameSet.end())
    {
        num++;
        modelstr.Format(L"Label%d", num);
    }
    group->setName(CStringA(modelstr).GetBuffer(0));
    group->addChild(geode);
    return group;

    // =====================================version 0.2
    // 得到exe执行路径.  
    //TCHAR tcExePath[MAX_PATH] = { 0 };
    //::GetModuleFileName(NULL, tcExePath, MAX_PATH);
    ////_tcsrchr() 反向搜索获得最后一个'\\'的位置，并返回该位置的指针  
    //TCHAR *pFind = _tcsrchr(tcExePath, '\\');
    //if (pFind != NULL)
    //{
    //    *pFind = '\0';
    //}
    //CString path = tcExePath;
    //path += "\\src\\";
    //CString coneFile = path + L"cone.obj";
    //osgDB::Options  *a = new osgDB::Options(std::string("noTriStripPolygons"));
    //ref_ptr<Node> node = osgDB::readNodeFile(
    //    CStringA(coneFile).GetBuffer(0), a);
    //node->getOrCreateStateSet()->setMode(GL_LIGHTING, StateAttribute::OFF);
    //// 查重名Label，修改新加的Label名，确保无重名Label

    //node->setName("Label0");
    //return node;

    // ====================================version 0.1
    //创建几何体  
    //ref_ptr<Geode> geode = new Geode();
    //ref_ptr<Geometry> geometry = new Geometry();
    //geode->addDrawable(geometry);
    ////光照模式关闭，这样从各个方向看到的图片才是一样的  
    //geode->getOrCreateStateSet()->setMode(GL_LIGHTING, StateAttribute::OFF);
    ////指定几何体的顶点坐标  
    //ref_ptr<Vec3Array> v = new Vec3Array();
    //v->push_back(Vec3(-1.0, 0.0, -1.0));
    //v->push_back(Vec3(1.0, 0.0, -1.0));
    //v->push_back(Vec3(1.0, 0.0, 1.0));
    //v->push_back(Vec3(-1.0, 0.0, 1.0));
    //geometry->setVertexArray(v.get());

    ////指定几何体的法向量坐标  
    //ref_ptr<Vec3Array> normal = new Vec3Array;
    //normal->push_back(Y_AXIS);
    //geometry->setNormalArray(normal.get());
    //geometry->setNormalBinding(Geometry::BIND_OVERALL);

    ////指定几何体的纹理坐标  
    //ref_ptr<Vec2Array> tcoords = new Vec2Array();
    //tcoords->push_back(Vec2(0.0f, 0.0f));
    //tcoords->push_back(Vec2(1.0f, 0.0f));
    //tcoords->push_back(Vec2(1.0f, 1.0f));
    //tcoords->push_back(Vec2(0.0f, 1.0f));
    //geometry->setTexCoordArray(0, tcoords.get());

    ////使用图元绘制几何体  
    //geometry->addPrimitiveSet(new DrawArrays(PrimitiveSet::QUADS, 0, 4));

    ////贴纹理,这里使用png格式或gif格式的透明图片都可以，但是只能是这两种格式，因为只有这两种格式的图片才可以实现透明  
    //ref_ptr<Texture2D> texture = new Texture2D;
    ////ref_ptr<Image> image=osgDB::readImageFile("forestWall.png");  
    //
    //CString pngFile = path + L"map_marker_16px.png";    
    //ref_ptr<Image> image = osgDB::readImageFile(
    //    CStringA(path).GetBuffer(0));

    //texture->setImage(image);
    //geometry->getOrCreateStateSet()->setTextureAttributeAndModes(0, texture, StateAttribute::ON);

    ////要想看到png图片的透明效果，需要开启混合模式  
    //geometry->getOrCreateStateSet()->setMode(GL_BLEND, StateAttribute::ON);
    //geometry->getOrCreateStateSet()->setRenderingHint(StateSet::TRANSPARENT_BIN);
    //

    //ref_ptr<Group> group = new Group;

    //group->setName("Label");
    //group->addChild(node);
    //return group;
}

void CEventHandler::RectifyH(bool rectify_H)
{
    _rectify_H = rectify_H;
}

bool CEventHandler::RectifyH(osgViewer::Viewer* viewer, const osgGA::GUIEventAdapter & ea)
{

    osgUtil::LineSegmentIntersector::Intersections intersections;
    if (viewer->computeIntersections(ea, intersections))
    {
        const osgUtil::LineSegmentIntersector::Intersection& hit = *intersections.begin();

        bool handleMovingModels = false;
        const NodePath& nodePath = hit.nodePath;
        for (NodePath::const_iterator nitr = nodePath.begin();
             nitr != nodePath.end();
             ++nitr)
        {
            const MatrixTransform* cube = dynamic_cast<const MatrixTransform*>(*nitr);
            if (cube)
            {
                if (cube->getName() == "Matrix") handleMovingModels = true;
            }
        }

        Vec3 positionLabel = handleMovingModels ? hit.getLocalIntersectPoint() : hit.getWorldIntersectPoint();

        _vec_rectify_H.push_back(positionLabel);
    }

    int pn = _vec_rectify_H.size();
    if (pn > 3)
    {
        for (int i = 2; i > -1;--i)
        {
            _vec_rectify_H[i] = _vec_rectify_H[pn - 1 - (2 - i)];
        }
        _vec_rectify_H.erase(_vec_rectify_H.begin() + 3, _vec_rectify_H.end());
    }

    pn = _vec_rectify_H.size();
    if (pn == 3)
    {
        Vec3 A(_vec_rectify_H[0] - _vec_rectify_H[1]), B(_vec_rectify_H[1] - _vec_rectify_H[2]);
        Vec3 n = A ^ B;
        Quat quat;
        //根据两个向量计算四元数  
        quat.makeRotate(n, Z_AXIS);

        Group* root = dynamic_cast<Group*>(viewer->getSceneData());
        if (!root)
            return false;
                
        CfindNodeVisitor fv("Init Model");
        root->accept(fv);
        fv.apply(*root);
        Node *node = fv.getLast();

        if (node)
        {
            MatrixTransform* trans = new MatrixTransform;
            trans->setName("Matrix");
            Vec3 node_center = node->getBound().center();
            float r = node->getBound().radius();
            trans->setMatrix(Matrix::rotate(quat)
                             * Matrix::translate(
                             Vec3(node_center.x() + r * 2, 
                             node_center.y(), 
                             38))
                             );
            trans->addChild(node);
            ref_ptr<Group> initGroup = new Group;
            initGroup->setName("Rectifyed Model");
            initGroup->addChild(trans);
            root->addChild(initGroup);
            _rectify_H = false;
            return true;
        }
    }
    return false;
}
