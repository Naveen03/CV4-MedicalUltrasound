using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Xml;
namespace UTScannerApp
{
    public partial class frmPatientInfo : Form
    {
        public delegate void LoadPatientInfoEvtHandler();
        public event LoadPatientInfoEvtHandler LoadPatientData;

        public delegate void ProbeChangedEvtHandler(int probeID);
        public event ProbeChangedEvtHandler ProbeChanged;

        string[] humanType;
        int selectedHumanIdx_;
        public frmPatientInfo()
        {
            InitializeComponent();
           InitializeMember();
          //  InitializeProbe();
        }
        void InitializeProbe()
        {
        //    this.tip.SetToolTip(this.btnBladder, "Bladder");
        //    this.tip.SetToolTip(this.btnGlottis, "Glottis");
        //    this.tip.SetToolTip(this.btnHeart, "Heart");
        //    this.tip.SetToolTip(this.btnKidney, "Kidney");
        //    this.tip.SetToolTip(this.btnLegBone, "LegBone");
        //    this.tip.SetToolTip(this.btnLung, "Lung");
        //    this.tip.SetToolTip(this.btnNeuron, "Neuron");
        //    this.tip.SetToolTip(this.btnSpinal, "Spinal");
        //    this.tip.SetToolTip(this.btnSpleen, "Spleen");
        //    this.tip.SetToolTip(this.btnBreast, "Breast");
        //    this.tip.SetToolTip(this.btnUterus, "Uterus");


            //this.humanType = new string[3];

            //this.humanType[0] = "Male";
            //this.humanType[1] = "Female";
            //this.humanType[2] = "Baby";
            //this.selectedHumanIdx_ = 0;
            //LoadHumanType();
        }
        void InitializeMember()
        {
            clsConstant.Instance.isPatientInfoOpen = false;
            clsConstant.Instance.allPatientDir_ = null;
            clsConstant.Instance.selectedPatientImage_ = String.Empty;
            clsConstant.Instance.sampleFreq_ = 0f;
            clsConstant.Instance.maxDepth_ = 0f;
        }
        void LoadSettings()
        {
            if (this.cmbPatientId.Items.Count > 0)
            {
                this.cmbPatientId.Items.Clear();
                clsConstant.Instance.allPatientDir_ = null;
            }
            clsConstant.Instance.isInlineProcess = true;
            string inputDir =System.IO.Path.Combine( Application.StartupPath, "Input");// Application.StartupPath.Substring(0,Application.StartupPath.LastIndexOf("\\")+1);
          //  inputDir = inputDir + "Input";
            if(System.IO.Directory.Exists(inputDir))
            {
                clsConstant.Instance.allPatientDir_ = Directory.GetDirectories(inputDir,"*", SearchOption.TopDirectoryOnly).ToList<string>();
                this.cmbPatientId.Items.Add("New");
                foreach (string dir in clsConstant.Instance.allPatientDir_)
                    this.cmbPatientId.Items.Add(new DirectoryInfo(dir).Name);
            }

        }

        private void frmPatientInfo_Load(object sender, EventArgs e)
        {
           
            LoadSettings();
        }

        private void cmbPatientId_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (this.cmbPatientId.SelectedIndex > 0)
            {
                this.tabCtrl.TabPages[1].Visible = false;
                this.btnLoad.Text = "Load";
                clsConstant.Instance.isInlineProcess = false;
                this.txtPatientID.Visible = false;
                String xmlFilename = clsConstant.Instance.allPatientDir_[cmbPatientId.SelectedIndex-1] + "\\" + this.cmbPatientId.Text + ".xml";
                if (System.IO.File.Exists(xmlFilename))
                {

                    clsConstant.Instance.patientID =this.cmbPatientId.Text;
                    clsConstant.Instance.selectedPatientImage_ = clsConstant.Instance.allPatientDir_[cmbPatientId.SelectedIndex-1] + "\\" + this.cmbPatientId.Text + ".png";
                    clsConstant.Instance.selectedPatientDir_ = clsConstant.Instance.allPatientDir_[cmbPatientId.SelectedIndex-1];
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.Load(xmlFilename);

                    XmlNodeList tempNodeList = xmlDoc.GetElementsByTagName("Name");
                    if (tempNodeList.Count > 0)
                    {
                        this.txtPatientName.Text = tempNodeList[0].InnerText;
                        clsConstant.Instance.paientName = tempNodeList[0].InnerText; 
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("Gender");
                    if (tempNodeList.Count > 0)
                    {
                        if(tempNodeList[0].InnerText.Equals("Male"))
                        {
                            this.rbtnMale.Checked = true;
                        }
                        else
                        {
                            this.rbtnFemale.Checked = true;
                        }
                        
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("BirthDate");
                    if (tempNodeList.Count > 0)
                    {
                        this.dtBirthDate.Value = Convert.ToDateTime(tempNodeList[0].InnerText);
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("Age");
                    if (tempNodeList.Count > 0)
                    {
                        this.numAge.Value =Convert.ToInt32( tempNodeList[0].InnerText);
                    }

                    tempNodeList = xmlDoc.GetElementsByTagName("Hospital");
                    if (tempNodeList.Count > 0)
                    {
                        this.txtHospitalName.Text=tempNodeList[0].InnerText;
                        clsConstant.Instance.hospitalName = tempNodeList[0].InnerText; 
                    }

                    tempNodeList = xmlDoc.GetElementsByTagName("Doctor");
                    if (tempNodeList.Count > 0)
                    {
                        this.txtDoctorInfo.Text = tempNodeList[0].InnerText;
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("Height");
                    if (tempNodeList.Count > 0)
                    {
                        this.numHeight.Value = Convert.ToInt32(tempNodeList[0].InnerText);
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("Weight");
                    if (tempNodeList.Count > 0)
                    {
                        this.numWeight.Value = Convert.ToInt32(tempNodeList[0].InnerText);
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("History");
                    if (tempNodeList.Count > 0)
                    {
                        this.txtHistory.Text =tempNodeList[0].InnerText;
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("ProbeType");
                    if (tempNodeList.Count > 0)
                    {
                        clsConstant.Instance.probeType = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToInt32(tempNodeList[0].InnerText);
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("SamplingFreq");
                    if (tempNodeList.Count > 0)
                    {
                        clsConstant.Instance.sampleFreq_ = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0: Convert.ToDouble(tempNodeList[0].InnerText);
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("MaxDepth");
                    if (tempNodeList.Count > 0)
                    {
                        clsConstant.Instance.maxDepth_ = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToDouble(tempNodeList[0].InnerText);
                    }
                    tempNodeList = xmlDoc.GetElementsByTagName("ApertureSize");
                    if (tempNodeList.Count > 0)
                    {
                        clsConstant.Instance.apertureSize_ = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToDouble(tempNodeList[0].InnerText);
                    }
                }
            }
            else
            {
                clsConstant.Instance.patientID = $"P{System.DateTime.Now.ToString("dd-MM-yyyy hh:mm:ss")}";
                this.txtPatientID.Text = clsConstant.Instance.patientID;
                this.txtPatientID.Enabled = false;
                this.txtPatientID.Visible = true;
                this.tabCtrl.TabPages[1].Visible = true;
                this.btnLoad.Text = "Start Scan";
            }

        }
        public void SavePaientInfo()
        {
            try
            {
                if (cmbPatientId.SelectedIndex > 0)
                {
                    String xmlFilename = clsConstant.Instance.allPatientDir_[cmbPatientId.SelectedIndex - 1] + "\\" + this.cmbPatientId.Text + ".xml";
                    if (System.IO.File.Exists(xmlFilename))
                    {
                        XmlDocument xmlDoc = new XmlDocument();
                        xmlDoc.Load(xmlFilename);
                        XmlNodeList tempNodeList = xmlDoc.GetElementsByTagName("Name");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.txtPatientName.Text;
                            clsConstant.Instance.paientName = tempNodeList[0].InnerText;
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("Gender");
                        if (tempNodeList.Count > 0)
                        {
                            if (this.rbtnMale.Checked)
                            {
                                tempNodeList[0].InnerText = "Male";
                            }
                            else
                            {
                                tempNodeList[0].InnerText = "Female";
                            }
                        }

                        tempNodeList = xmlDoc.GetElementsByTagName("BirthDate");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.dtBirthDate.Value.ToString("dd-MM-yyyy");
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("Age");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.numAge.Value.ToString();
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("Hospital");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.txtHospitalName.Text;
                            clsConstant.Instance.hospitalName = this.txtHospitalName.Text;
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("Doctor");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.txtDoctorInfo.Text;
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("Height");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.numHeight.Value.ToString();
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("Weight");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.numWeight.Value.ToString();
                        }
                        tempNodeList = xmlDoc.GetElementsByTagName("History");
                        if (tempNodeList.Count > 0)
                        {
                            tempNodeList[0].InnerText = this.txtHistory.Text;
                        }
                        xmlDoc.Save(xmlFilename);
                        MessageBox.Show("Saved..");
                    }
                }
            }
            catch (Exception xptn)
            {

            }
        }
        private void btnSave_Click(object sender, EventArgs e)
        {
            SavePaientInfo();
        }
        public void LoadPatientDatatoVisualizer()
        {
            LoadPatientData();
           
        }

        private void btnLoad_Click(object sender, EventArgs e)
        {
            if(clsConstant.Instance.isInlineProcess)
            {
                ReadInlineProcessImg();
                LoadPatientDatatoVisualizer();
            }
            else //PostProcess
                LoadPatientDatatoVisualizer();

            DialogResult = DialogResult.OK;
            clsConstant.Instance.isPatientInfoOpen = false;
            this.Close();
        }
        void ReadInlineProcessImg()
        {
            String xmlFilename = clsConstant.Instance.allPatientDir_[0] + "\\Patient1.xml";
            if (System.IO.File.Exists(xmlFilename))
            {

                clsConstant.Instance.patientID = this.txtPatientID.Text;
                clsConstant.Instance.selectedPatientImage_ = clsConstant.Instance.allPatientDir_[0] + "\\Patient1.png";
                clsConstant.Instance.selectedPatientDir_ = clsConstant.Instance.allPatientDir_[0];
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.Load(xmlFilename);  
                clsConstant.Instance.paientName = this.txtPatientName.Text;
                clsConstant.Instance.hospitalName = this.txtHospitalName.Text;
                XmlNodeList tempNodeList = xmlDoc.GetElementsByTagName("ProbeType");
                if (tempNodeList.Count > 0)
                {
                    clsConstant.Instance.probeType = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToInt32(tempNodeList[0].InnerText);
                }
                tempNodeList = xmlDoc.GetElementsByTagName("SamplingFreq");
                if (tempNodeList.Count > 0)
                {
                    clsConstant.Instance.sampleFreq_ = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToDouble(tempNodeList[0].InnerText);
                }
                tempNodeList = xmlDoc.GetElementsByTagName("MaxDepth");
                if (tempNodeList.Count > 0)
                {
                    clsConstant.Instance.maxDepth_ = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToDouble(tempNodeList[0].InnerText);
                }
                tempNodeList = xmlDoc.GetElementsByTagName("ApertureSize");
                if (tempNodeList.Count > 0)
                {
                    clsConstant.Instance.apertureSize_ = String.IsNullOrEmpty(tempNodeList[0].InnerText) ? 0 : Convert.ToDouble(tempNodeList[0].InnerText);
                }
            }
        }
        private void dtBirthDate_ValueChanged(object sender, EventArgs e)
        {
            this.numAge.Value = (System.DateTime.Now.Year - this.dtBirthDate.Value.Year);
        }

        private void frmPatientInfo_Shown(object sender, EventArgs e)
        {
            clsConstant.Instance.isPatientInfoOpen = true;
        }

        private void frmPatientInfo_FormClosing(object sender, FormClosingEventArgs e)
        {
            clsConstant.Instance.isPatientInfoOpen = false;

        }

        private void rbtnConvex_CheckedChanged(object sender, EventArgs e)
        {
            ProbeChanged(1);
        }

        private void rbtnTR_CheckedChanged(object sender, EventArgs e)
        {
            ProbeChanged(2);
        }

        private void rbtnLinear_CheckedChanged(object sender, EventArgs e)
        {
            ProbeChanged(3);
        }
        public void ChangeProbeFromTP(int probeID)
        {
            if (probeID == 1)
                this.rbtnConvex.Checked = true;
            else if (probeID == 2)
                this.rbtnTR.Checked = true;
            else if (probeID == 3)
                this.rbtnLinear.Checked = true;
        }
        //private void btnNext_Click(object sender, EventArgs e)
        //{
        //    if (this.selectedHumanIdx_ < this.humanType.Length - 1)
        //    {
        //        this.selectedHumanIdx_++;
        //    }
        //    else
        //    {
        //        this.selectedHumanIdx_ = 0;
        //    }
        //    LoadHumanType();
        //}
        //void LoadHumanType()
        //{
        //    if (this.humanType[this.selectedHumanIdx_].Equals("Baby"))
        //    {
        //        this.btnBladder.Visible = false;
        //        this.btnGlottis.Visible = false;
        //        this.btnHeart.Visible = true;
        //        this.btnKidney.Visible = false;
        //        this.btnLegBone.Visible = false;
        //        this.btnLung.Visible = false;
        //        this.btnNeuron.Visible = false;
        //        this.btnSpinal.Visible = false;
        //        this.btnSpleen.Visible = false;
        //        this.btnUterus.Visible = false;
        //        this.btnBreast.Visible = false;
        //    }
        //    else if (this.humanType[this.selectedHumanIdx_].Equals("Male"))
        //    {
        //        this.btnBladder.Visible = true;
        //        this.btnGlottis.Visible = true;
        //        this.btnHeart.Visible = true;
        //        this.btnKidney.Visible = true;
        //        this.btnLegBone.Visible = true;
        //        this.btnLung.Visible = true;
        //        this.btnNeuron.Visible = true;
        //        this.btnSpinal.Visible = true;
        //        this.btnSpleen.Visible = true;
        //        this.btnUterus.Visible = false;
        //        this.btnBreast.Visible = false;
        //    }
        //    else if (this.humanType[this.selectedHumanIdx_].Equals("Female"))
        //    {
        //        this.btnGlottis.Visible = true;
        //        this.btnHeart.Visible = true;
        //        this.btnKidney.Visible = true;
        //        this.btnLegBone.Visible = true;
        //        this.btnLung.Visible = true;
        //        this.btnNeuron.Visible = true;
        //        this.btnSpinal.Visible = true;
        //        this.btnSpleen.Visible = true;
        //        this.btnUterus.Visible = true;
        //        this.btnBreast.Visible = true;
        //        this.btnBladder.Visible = false;
        //    }

        //    this.lblCaption.Text = this.humanType[this.selectedHumanIdx_];
        //    this.pbxHumanType.Image = new Bitmap(Application.StartupPath + "\\" + this.humanType[this.selectedHumanIdx_] + ".png");
        //}

        //private void btnPrev_Click(object sender, EventArgs e)
        //{
        //    if (this.selectedHumanIdx_ > 0)
        //    {
        //        this.selectedHumanIdx_--;
        //    }
        //    else
        //    {
        //        this.selectedHumanIdx_ = this.humanType.Length - 1;
        //    }
        //    LoadHumanType();
        //}
    }
}
