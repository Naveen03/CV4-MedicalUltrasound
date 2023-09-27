using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using WeifenLuo.WinFormsUI.Docking;
using System.IO;
using System.IO.Ports;
using UTImgProcess;
using System.Xml;
namespace UTScannerApp
{
    public partial class Home : Form
    {
        frmInput frmInput_;
        frmApplication frmApplication_;
        frmView frmView_;
        frmSerialPortSettings frmSerialPortSettings_;
        frmPatientInfo frmPatientInfo_;
        frmTGC frmTGC_;
        frmCapture frmCapture_;
        int deph_;
        int cols_;
        frmUTInfo frmUTInfo_;
        SerialPort serialPortTP_;
        SerialPort serialPortMC_;
        byte[] dataBufferFromNextionDevice_;
        int numberOfBytes;
        clsImageProcess clsImageProcess_;
        List<double[,]> allInputData_;
        double[,] imgData_;
        string localFolderPath_ = System.Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
        string FILENAME_LASTLAYOUT = "UTScanner.lyt";
        string APP_LOG = "appLog.csv";
        String appLogPath = String.Empty;
        bool colorflowCursor = false;
        public Home()
        {
            InitializeComponent();
            try
            {
                InitializeGUI();
                ReadSerialPortSettings();
                InitializeSerialPort();
            }
            catch (Exception xptn)
            {
                MessageBox.Show(xptn.Message);
            }
        }
        void InitializeGUI()
        {
            this.localFolderPath_ = this.localFolderPath_ + "\\UTScannerApp";
            if (!Directory.Exists(this.localFolderPath_))
                Directory.CreateDirectory(this.localFolderPath_);

            String lastLayoutSettingsFileName = this.localFolderPath_ + "\\" + FILENAME_LASTLAYOUT;
            this.appLogPath = this.localFolderPath_ + "\\" + APP_LOG;

            clsImageProcess_ = new clsImageProcess();
            imgData_ = null;

            this.frmInput_ = new frmInput();
            this.frmInput_.ImportImage += openPatientInfoWindow;
            this.frmInput_.LoadTGC += LoadTGC;
            this.frmInput_.NeedleEnable += EnableNeedle; ;
            this.frmInput_.ShowApplicaion += ShowApplicaion;
            this.frmInput_.ApplyEnhancementFilter += ApplyEnhancementFilter;
            this.frmInput_.ApplyColorFlow += ApplyColorFlow;
            this.frmInput_.ChangedGain += ApplyGain;
            this.frmInput_.ChangedDepth += ApplyDepth;
            this.frmInput_.GammaChanged += ApplyGammaFilter;
            this.frmInput_.ShwColorFlowCursor += ShwHideColorFlowCursor;
            this.frmInput_.ApplyColorScale += FrmInput__ApplyColorScale;
            this.frmInput_.ApplyAutoColorScale += FrmInput__ApplyAutoColorScale;
            this.frmInput_.ApplyDeSpeckleFilter += ApplyDeSpeckleFilter;
            this.frmInput_.ApplyDynamicFilter += ApplyDynamicFilter;
            this.frmInput_.doGPUProcess += doGPUProcess;

            frmApplication_ = new frmApplication();
            this.frmUTInfo_ = new frmUTInfo();
            this.frmView_ = new frmView();
            this.frmView_.SaveCurrentFrame += SaveCurrentFrame;
            this.frmView_.ColorflowCursorChanged += FrmView__ColorflowCursorChanged;
            frmCapture_ = new frmCapture();

            if (System.IO.File.Exists(lastLayoutSettingsFileName))
                this.dpnl_.LoadFromXml(lastLayoutSettingsFileName, new DeserializeDockContent(this.GetDockContent));
            else
                loadDefaultLayout();

        }
        private void doGPUProcess()
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ReadDatabyProbe());
            }
        }

        private void ApplyDynamicFilter(double dynamicParam)
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyDynamicFilter(this.frmView_.uc2DView_.imgData_, dynamicParam));
            }
        }
        private void ApplyDeSpeckleFilter()
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyDeSpeckleFilter(this.frmView_.uc2DView_.imgData_));
            }
        }

        private void FrmView__ColorflowCursorChanged()
        {
            try
            {
                if (colorflowCursor)
                {
                    //this.ApplyColorFlow();
                    List<double[]> overloadData = this.clsImageProcess_.ApplyColorFlow(this.frmView_.uc2DView_.imgData_, this.frmView_.GetColorflowCursorPoints());

                    if (overloadData != null)
                    {
                        this.frmView_.LoadColorFlowData(this.frmView_.uc2DView_.imgData_, overloadData);
                    }
                }
            }
            catch (Exception xptn)
            { }
        }

        private void FrmInput__ApplyAutoColorScale(bool isRGB)
        {
            this.frmView_.SetAutoColorScale(isRGB);
        }
        private void FrmInput__ApplyColorScale(bool isRGB, int min, int max)
        {
            this.frmView_.ApplyManualColorScale(isRGB, min, max);
        }

        private void ShwHideColorFlowCursor()
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                if (!colorflowCursor)
                    colorflowCursor = true;
                else
                    colorflowCursor = false;

                this.frmView_.ShowHideColorflowCursor(colorflowCursor);
            }
        }

        private void ApplyGain(double gain)
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyGain(this.frmView_.uc2DView_.imgData_, gain));
            }
        }
        private void ApplyGammaFilter(double[] yPts)
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyGammaFilter(this.frmView_.uc2DView_.imgData_, yPts));
            }
        }
        private void ApplyDepth(double depth)
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyDepth(this.frmView_.uc2DView_.imgData_, depth));
            }
        }
        void ReadSerialPortSettings()
        {
            if (File.Exists(clsConstant.Instance.serialPortConfigFile))
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(clsConstant.Instance.serialPortConfigFile);
                XmlNodeList tempNodeList = xmlDoc.GetElementsByTagName("TPortName");
                if (tempNodeList.Count > 0)
                    clsConstant.Instance._TPportName = tempNodeList[0].InnerText;

                tempNodeList = xmlDoc.GetElementsByTagName("TPBautRate");
                if (tempNodeList.Count > 0)
                    clsConstant.Instance._TPbautRate = Convert.ToInt32(tempNodeList[0].InnerText);

                tempNodeList = xmlDoc.GetElementsByTagName("TPDatabit");
                if (tempNodeList.Count > 0)
                    clsConstant.Instance._TPDatabit = Convert.ToInt32(tempNodeList[0].InnerText);

                tempNodeList = xmlDoc.GetElementsByTagName("MCPortName");
                if (tempNodeList.Count > 0)
                    clsConstant.Instance._MCportName = tempNodeList[0].InnerText;

                tempNodeList = xmlDoc.GetElementsByTagName("MCBautRate");
                if (tempNodeList.Count > 0)
                    clsConstant.Instance._MCbautRate = Convert.ToInt32(tempNodeList[0].InnerText);

                tempNodeList = xmlDoc.GetElementsByTagName("MCDatabit");
                if (tempNodeList.Count > 0)
                    clsConstant.Instance._MCDatabit = Convert.ToInt32(tempNodeList[0].InnerText);

            }
        }
        void InitializeSerialPort()
        {
            try
            {
                if (this.serialPortTP_ != null)
                    this.serialPortTP_ = null;

                serialPortTP_ = new SerialPort();
                serialPortTP_.PortName = String.IsNullOrEmpty(clsConstant.Instance._TPportName) ? "COM1" : clsConstant.Instance._TPportName;
                serialPortTP_.BaudRate = clsConstant.Instance._TPbautRate;
                serialPortTP_.DataBits = clsConstant.Instance._TPDatabit;
                serialPortTP_.StopBits = StopBits.One;
                serialPortTP_.Open();
                serialPortTP_.DataReceived += new SerialDataReceivedEventHandler(port_DataReceived);

                if (serialPortMC_ != null)
                    serialPortMC_ = null;
                serialPortMC_ = new SerialPort();
                serialPortMC_.PortName = String.IsNullOrEmpty(clsConstant.Instance._MCportName) ? "COM3" : clsConstant.Instance._MCportName;
                serialPortMC_.BaudRate = clsConstant.Instance._MCbautRate;
                serialPortMC_.DataBits = clsConstant.Instance._MCDatabit;
                serialPortMC_.StopBits = StopBits.One;
                serialPortMC_.Open();
                serialPortMC_.DataReceived += new SerialDataReceivedEventHandler(MCport_DataReceived);


            }
            catch (Exception xptn)
            {
                AppLog($"Home , InitializeSerialPort , {xptn.Message}");
            }
        }

        void SaveCurrentFrame(double[,] currentFrameData, Bitmap currentImg)
        {
            this.frmCapture_.capturedImage(currentFrameData, currentImg);
            if (frmCapture_.IsHidden || frmCapture_.IsDockStateValid(DockState.DockBottomAutoHide))
            {
                this.frmCapture_.Show(this.dpnl_);
                this.frmCapture_.DockState = DockState.DockBottom;
            }
        }
        void AppLog(String content)
        {
            using (StreamWriter sw = new StreamWriter(this.appLogPath, true))
            {
                sw.Write(content);
            }
        }

        private void MCport_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            try
            {
                numberOfBytes = serialPortMC_.BytesToRead;
                dataBufferFromNextionDevice_ = new byte[numberOfBytes];
                serialPortMC_.Read(dataBufferFromNextionDevice_, 0, numberOfBytes);
                this.Invoke(new EventHandler(DataUpdatetoUI));

            }
            catch (Exception xptn)
            {
                AppLog($"Home , MC_port_DataReceived , {xptn.Message}");
            }
        }
        private void port_DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            try
            {
                numberOfBytes = serialPortTP_.BytesToRead;
                dataBufferFromNextionDevice_ = new byte[numberOfBytes];
                serialPortTP_.Read(dataBufferFromNextionDevice_, 0, numberOfBytes);
                this.Invoke(new EventHandler(DataUpdatetoUI));
            }
            catch (Exception xptn)
            {
                AppLog($"Home , TP_port_DataReceived , {xptn.Message}");
            }
        }
        private void DataUpdatetoUI(object s, EventArgs e)
        {
            try
            {
                if (this.numberOfBytes > 0)
                {
                    this.frmView_.SetStatus("Code :" + this.dataBufferFromNextionDevice_[0]);
                    switch (this.dataBufferFromNextionDevice_[0])// Key
                    {
                        case 1://PatientInfo                             
                            openPatientInfoWindow();
                            break;
                        case 2://ProbeSelection
                            if (this.frmInput_.isEnableApplication)
                                this.frmInput_.isEnableApplication = false;
                            else
                                this.frmInput_.isEnableApplication = true;
                            ShowApplicaion(this.frmInput_.isEnableApplication);

                            break;
                        case 3://open TGC
                            LoadTGC();
                            break;
                        case 31://Close TGC
                            if (clsConstant.Instance.isTGCOpen)
                                frmTGC_.Close();
                            break;
                        case 11://Save PatienInfo
                            if (clsConstant.Instance.isPatientInfoOpen)
                                frmPatientInfo_.SavePaientInfo();
                            break;
                        case 12://Load PatienInfo
                            if (clsConstant.Instance.isPatientInfoOpen)
                                frmPatientInfo_.LoadPatientDatatoVisualizer();
                            break;
                        case 41://GraphSave
                            this.frmView_.uc2DView_.SaveGraph();
                            break;
                        case 42://GraphReset                            i
                            this.frmView_.uc2DView_.ResetGraph();
                            break;
                        case 43://GraphViewLayout
                            if (this.numberOfBytes > 1)
                                this.frmView_.ViewLayoutbyIdx(this.dataBufferFromNextionDevice_[1]);
                            break;
                        case 44://GraphView
                            if (this.numberOfBytes > 1)
                                this.frmView_.SetScanMode(this.dataBufferFromNextionDevice_[1]);
                            break;
                        case 45://GraphViewFrame

                            if (this.numberOfBytes > 1)
                                this.frmView_.LoadFramebyIndex(this.dataBufferFromNextionDevice_[1]);
                            break;
                        case 81:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam1.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam1);
                                }
                            }
                            break;
                        case 82:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam2.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam2);
                                }
                            }
                            break;
                        case 83:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam3.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam3);
                                }
                            }
                            break;
                        case 84:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam4.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam4);
                                }
                            }
                            break;
                        case 85:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam5.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam5);
                                }
                            }
                            break;
                        case 86:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam6.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam6);
                                }
                            }
                            break;
                        case 87:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam7.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam7);
                                }
                            }
                            break;
                        case 88:
                            if (clsConstant.Instance.isTGCOpen)
                            {
                                if (this.dataBufferFromNextionDevice_[1] <= 150)
                                {
                                    frmTGC_.tbParam8.Value = this.dataBufferFromNextionDevice_[1];
                                    frmTGC_.ApplyTGCValue(frmTGC_.tbParam8);

                                }
                            }
                            break;
                        case 89:
                            if (this.dataBufferFromNextionDevice_[1] <= 200)
                            {
                                frmInput_.SetGain((int)this.dataBufferFromNextionDevice_[1]);
                            }
                            break;
                        case 90:
                            if (this.dataBufferFromNextionDevice_[1] <= 80)
                            {
                                // frmInput_.SetDepth((int)this.dataBufferFromNextionDevice_[1]);
                            }
                            break;
                        case 91://Load PatienInfo
                            if (clsConstant.Instance.isPatientInfoOpen)
                                frmPatientInfo_.ChangeProbeFromTP(1);
                            break;
                        case 92://Load PatienInfo
                            if (clsConstant.Instance.isPatientInfoOpen)
                                frmPatientInfo_.ChangeProbeFromTP(2);
                            break;
                        case 93://Load PatienInfo
                            if (clsConstant.Instance.isPatientInfoOpen)
                                frmPatientInfo_.ChangeProbeFromTP(3);
                            break;

                        case 121://B-Mode
                            if (this.frmView_.uc2DView_.imgData_ != null)
                                frmView_.SetScanMode(0);
                            break;
                        case 122://M-Mode
                            if (this.frmView_.uc2DView_.imgData_ != null)
                                frmView_.SetScanMode(5);
                            break;
                        case 123://Messurement
                            if (this.frmView_.uc2DView_.imgData_ != null)
                                frmView_.ShowHideLinearMeasurement();
                            break;


                    }

                }
            }
            catch (Exception xptn)
            {
                AppLog($"Home , DataUpdatetoUI , {xptn.Message}");
            }
        }

        private void ApplyEnhancementFilter(int enHanceID)//s_option, int niter, float kappa, float lambda, float clahe_clip)
        {
            this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyEnhanceFilter(this.frmView_.uc2DView_.imgData_, enHanceID));//s_option, niter, kappa, lambda, clahe_clip));

        }
        private void ApplyColorFlow()
        {
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                if (!colorflowCursor)
                    ShwHideColorFlowCursor();

                //List<double[]> overloadData = this.clsImageProcess_.ApplyColorFlow(this.frmView_.uc2DView_.imgData_, this.frmView_.GetColorflowCursorPoints());

                // if (overloadData != null)
                // {
                //     this.frmView_.LoadColorFlowData(this.frmView_.uc2DView_.imgData_, overloadData);
                // }
            }
        }
        void loadDefaultLayout()
        {
            this.frmInput_.Show(this.dpnl_);
            this.frmInput_.DockState = DockState.DockLeft;

            this.frmView_.Show(this.dpnl_);
            this.frmView_.DockState = DockState.Document;

            this.frmUTInfo_.Show(this.dpnl_);
            this.frmUTInfo_.DockState = DockState.DockRight;
        }
        protected IDockContent GetDockContent(String dockContentTypeName)
        {
            IDockContent matchingDockContent = null;

            if (dockContentTypeName == this.frmInput_.GetType().ToString())
            {
                matchingDockContent = this.frmInput_;
            }

            if (dockContentTypeName == this.frmView_.GetType().ToString())
            {
                matchingDockContent = this.frmView_;
            }
            if (dockContentTypeName == this.frmApplication_.GetType().ToString())
            {
                matchingDockContent = this.frmApplication_;
            }
            if (dockContentTypeName == this.frmUTInfo_.GetType().ToString())
            {
                matchingDockContent = this.frmUTInfo_;
            }

            return matchingDockContent;
        }
        void readImgasArray(string imgPath)
        {
            Bitmap inputImg = new Bitmap(imgPath);
            Color pixelColor;

            if (this.imgData_ != null)
                this.imgData_ = null;

            this.imgData_ = new double[inputImg.Width, inputImg.Height];
            for (int rIdx = 0; rIdx < inputImg.Height; rIdx++)
            {
                for (int cIdx = 0; cIdx < inputImg.Width; cIdx++)
                {
                    pixelColor = inputImg.GetPixel(cIdx, rIdx);
                    this.imgData_[cIdx, rIdx] = pixelColor.R;
                }
            }
            inputImg = null;
        }

        void readAllData(string inputDir)
        {
            try
            {
                if (allInputData_ != null)
                    allInputData_ = null;

                string[] allDataFile = System.IO.Directory.GetFiles(inputDir, "*.csv");
                if (allDataFile.Length > 0)
                {

                    this.allInputData_ = new List<double[,]>();
                    if (clsConstant.Instance.probeType == 1)
                    {
                        for (int frmIdx = 1; frmIdx <= allDataFile.Length; frmIdx++)
                        {
                            if (System.IO.File.Exists(inputDir + "\\" + "frame" + frmIdx + ".csv"))
                            {
                                this.allInputData_.Add(new double[this.cols_, this.deph_]);
                                string[] values = System.IO.File.ReadAllLines(inputDir + "\\" + "frame" + frmIdx + ".csv");
                                int idx = 0;
                                for (int cIdx = 0; cIdx < this.cols_; cIdx++)
                                {
                                    for (int rIdx = 0; rIdx < this.deph_; rIdx++)
                                    {
                                        this.allInputData_[frmIdx - 1][cIdx, rIdx] = !String.IsNullOrEmpty(values[idx]) ? Convert.ToDouble(values[idx]) : 0;
                                        idx++;
                                    }
                                }
                            }

                        }
                    }
                    else if (clsConstant.Instance.probeType == 2)
                    {
                        if (System.IO.File.Exists(inputDir + "\\CarotidHeader.csv"))
                        {
                            string[] values = System.IO.File.ReadAllLines(inputDir + "\\CarotidHeader.csv");
                            this.cols_ = Convert.ToInt32(values[18]) * Convert.ToInt32(values[2]);
                            this.deph_ = Convert.ToInt32(values[0]);//row                 512          
                            int width = Convert.ToInt32(values[2]);
                            int extra = Convert.ToInt32(values[18]);
                            this.allInputData_.Add(new double[this.deph_, this.cols_]);

                            string[] allData = System.IO.File.ReadAllLines(inputDir + "\\CarotidFlow.csv");
                            int rIdx = 0; int cIdx = 0;
                            foreach (string rData in allData)
                            {
                                string[] cData = rData.Split(',');
                                cIdx = 0;
                                foreach (string data in cData)
                                {
                                    this.allInputData_[0][rIdx, cIdx] = !String.IsNullOrEmpty(data) ? Convert.ToDouble(data) : 0;
                                    cIdx++;
                                }
                                rIdx++;
                            }

                        }

                    }
                }
            }
            catch (Exception xptn)
            {
                MessageBox.Show(xptn.Message);
            }
        }
        void openPatientInfoWindow()
        {

            if (!clsConstant.Instance.isPatientInfoOpen)
            {
                if (frmPatientInfo_ != null)
                    this.frmPatientInfo_ = null;
                this.frmPatientInfo_ = new frmPatientInfo();
                this.frmPatientInfo_.LoadPatientData += FrmPatientInfo__LoadPatientData;
                this.frmPatientInfo_.ProbeChanged += FrmPatientInfo__ProbeChanged;
                frmPatientInfo_.Show();

            }
            else
                frmPatientInfo_.BringToFront();
        }

        private void FrmPatientInfo__ProbeChanged(int probeID)
        {
            //try
            //{
            //    if (serialPortMC_.IsOpen)
            //    {
            //        // byte[] data= new byte[1];
            //        //  data[0] = (byte)probeID;
            //        serialPortMC_.WriteLine(probeID.ToString());
            //    }
            //    if (serialPortTP_.IsOpen)
            //    {
            //        // byte[] data= new byte[1];
            //        //  data[0] = (byte)probeID;
            //        serialPortTP_.WriteLine(probeID.ToString());
            //        this.frmView_.SetStatus("Send Data to TP & MC: " + probeID);
            //    }

            //}
            //catch (Exception xptn)
            //{
            //    AppLog($"Home , MP_port_Write , {xptn.Message}");
            //}
            //try
            //{
            //    if(serialPortMC_.IsOpen)
            //    {
            //        byte[] data= new byte[1];
            //        data[0] = (byte)probeID;
            //        serialPortMC_.Write(data, 0, 1);
            //        this.frmView_.SetStatus("Send Data to MC : " + data[0]);
            //    }
            //}
            //catch(Exception xptn)
            //{
            //    AppLog($"Home , MP_port_Write , {xptn.Message}");
            //}
        }

        private void FrmPatientInfo__LoadPatientData()
        {
            if (colorflowCursor)
                ShwHideColorFlowCursor();

            importImagetoVisualizer();

        }

        void importImagetoVisualizer()
        {
            if (File.Exists(clsConstant.Instance.selectedPatientImage_))
            {
                this.deph_ = (int)clsConstant.Instance.maxDepth_;
                this.cols_ = (int)clsConstant.Instance.apertureSize_;
                //this.readImgasArray(frmPatientInfo.Instance.selectedPatientImage_);
                this.readAllData(clsConstant.Instance.selectedPatientDir_);
                //this.frmViewer_.loadImgData(this.imgData_);
                if (clsConstant.Instance.probeType == 2)
                {
                    this.allInputData_[0] = this.clsImageProcess_.LoadCarotidData(this.allInputData_[0]);
                }

                this.frmView_.loadImgData(this.allInputData_);
                this.frmUTInfo_.loadUTInfo(clsConstant.Instance.sampleFreq_, clsConstant.Instance.maxDepth_, clsConstant.Instance.apertureSize_);
            }
        }
        void ShowApplicaion(bool isEnable)
        {
            if (isEnable)
            {
                this.frmApplication_.Show(this.dpnl_);
                this.frmApplication_.DockState = DockState.Document;
            }
            else
            {
                this.frmApplication_.Hide();
            }

        }
        void EnableNeedle(double angle)
        {
            //if (this.frmInput_.isEnableNeedle)
            //{
            //    this.frmViewer_.drawNeedle(angle);
            //}
            //else
            //{
            //    this.frmViewer_.CleartheNeedle();
            //}
        }
        void LoadTGC()
        {

            if (!clsConstant.Instance.isTGCOpen)
            {
                if (frmTGC_ != null)
                    frmTGC_ = null;

                frmTGC_ = new frmTGC();
                frmTGC_.ApplyTGCFilter += FrmTGC__ApplyTGCFilter;
                frmTGC_.Show();
            }
            else
                frmTGC_.BringToFront();
        }

        private void FrmTGC__ApplyTGCFilter(double[] tgcParam)
        {
            //openCVFilter
            if (this.frmView_.uc2DView_.imgData_ != null)
            {
                this.frmView_.uc2DView_.LoadFramebyIndex(frmView_.imgIdx_);
                this.frmView_.uc2DView_.loadImgData(this.clsImageProcess_.ApplyTGC(this.frmView_.uc2DView_.imgData_, tgcParam));
            }
        }

        private void Home_FormClosing(object sender, FormClosingEventArgs e)
        {
            try
            {
                this.dpnl_.SaveAsXml(this.localFolderPath_ + "\\" + FILENAME_LASTLAYOUT);
            }
            catch (Exception xptn)
            {

            }
        }

        private void settingsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (frmSerialPortSettings_ != null)
                frmSerialPortSettings_ = null;

            frmSerialPortSettings_ = new frmSerialPortSettings();
            if (frmSerialPortSettings_.ShowDialog() == DialogResult.OK)
            {
                if (this.serialPortMC_ != null)
                {
                    if (this.serialPortMC_.IsOpen)
                        this.serialPortMC_.Close();
                }
                if (this.serialPortTP_ != null)
                {
                    if (this.serialPortTP_.IsOpen)
                        this.serialPortTP_.Close();
                }

                InitializeSerialPort();

            }
        }
    }
}
