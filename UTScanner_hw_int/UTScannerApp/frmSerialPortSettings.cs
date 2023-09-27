using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO.Ports;
using System.Xml;
namespace UTScannerApp
{
    public partial class frmSerialPortSettings : Form
    {

        public frmSerialPortSettings()
        {
            InitializeComponent();
            InitializeGUI();
        }
        void InitializeGUI()
        {
            try
            {
                
                this.cmbPortname.DataSource = SerialPort.GetPortNames().ToList<string>();
                this.cmbMCPort.DataSource = SerialPort.GetPortNames().ToList<string>();

                if (String.IsNullOrEmpty(clsConstant.Instance._MCportName))
                {
                    if (this.cmbMCPort.Items.Contains("COM3"))
                        this.cmbMCPort.SelectedItem = "COM3";
                }
                else
                {
                    this.cmbMCPort.SelectedItem = clsConstant.Instance._MCportName;
                }
                if (String.IsNullOrEmpty(clsConstant.Instance._TPportName))
                {
                    if (this.cmbPortname.Items.Contains("COM1"))
                        this.cmbPortname.SelectedItem = "COM1";
                }
                else
                    this.cmbPortname.SelectedItem = clsConstant.Instance._TPportName;



                if (System.IO.File.Exists(clsConstant.Instance.serialPortConfigFile))
                {
                    this.cmbMCPort.SelectedItem = clsConstant.Instance._MCportName;
                    this.numBautRate.Value = clsConstant.Instance._TPbautRate;
                    this.numDataBit.Value = clsConstant.Instance._TPDatabit;
                    this.numBR.Value = clsConstant.Instance._MCbautRate;
                    this.numMCDB.Value = clsConstant.Instance._MCDatabit;
                }
                else
                {
                    this.numBautRate.Value = 9600;
                    this.numDataBit.Value = 8;
                    clsConstant.Instance._MCDatabit = 8;
                    clsConstant.Instance._MCbautRate = 9600;

                    clsConstant.Instance._TPDatabit = 8;
                    clsConstant.Instance._TPbautRate = 9600;
                }
            }
            catch (Exception xptn)
            {

            }
        }

       
        void saveSerialPortConfig()
        {
            try
            {  
                if (System.IO.File.Exists(clsConstant.Instance.serialPortConfigFile))
                    {
                        XmlDocument xmlDoc = new XmlDocument();
                        xmlDoc.Load(clsConstant.Instance.serialPortConfigFile);
                        
                        XmlNodeList tempNodeList = xmlDoc.GetElementsByTagName("TPortName");  
                        if (tempNodeList.Count > 0)
                            tempNodeList[0].InnerText = clsConstant.Instance._TPportName;
                        
                        tempNodeList = xmlDoc.GetElementsByTagName("TPBautRate");
                        if (tempNodeList.Count > 0)
                            tempNodeList[0].InnerText = clsConstant.Instance._TPbautRate.ToString();

                        tempNodeList = xmlDoc.GetElementsByTagName("TPDatabit");
                        if (tempNodeList.Count > 0)
                            tempNodeList[0].InnerText = clsConstant.Instance._TPDatabit.ToString();

                        tempNodeList = xmlDoc.GetElementsByTagName("MCPortName");
                        if (tempNodeList.Count > 0)
                            tempNodeList[0].InnerText = clsConstant.Instance._MCportName;

                        tempNodeList = xmlDoc.GetElementsByTagName("MCBautRate");
                        if (tempNodeList.Count > 0)
                            tempNodeList[0].InnerText = clsConstant.Instance._MCbautRate.ToString();

                    tempNodeList = xmlDoc.GetElementsByTagName("MCDatabit");
                    if (tempNodeList.Count > 0)
                        tempNodeList[0].InnerText = clsConstant.Instance._MCDatabit.ToString();

                    xmlDoc.Save(clsConstant.Instance.serialPortConfigFile);
                    }
                else
                {
                    using (XmlWriter writer = XmlWriter.Create(clsConstant.Instance.serialPortConfigFile))
                    {
                        writer.WriteStartElement("SerialPortConfig");
                        writer.WriteElementString("TPortName", clsConstant.Instance._TPportName);
                        writer.WriteElementString("TPBautRate", clsConstant.Instance._TPbautRate.ToString());
                        writer.WriteElementString("TPDatabit", clsConstant.Instance._TPDatabit.ToString());

                        writer.WriteElementString("MCPortName", clsConstant.Instance._MCportName);
                        writer.WriteElementString("MCBautRate", clsConstant.Instance._MCbautRate.ToString());
                        writer.WriteElementString("MCDatabit", clsConstant.Instance._MCDatabit.ToString());

                        writer.WriteEndElement();
                        writer.Flush();
                    }
                }
            }
            catch (Exception xptn)
            {
               
            }
        }
        private void frmSerialPortSettings_FormClosing(object sender, FormClosingEventArgs e)
        {
                clsConstant.Instance._TPportName = this.cmbPortname.SelectedItem.ToString();
                clsConstant.Instance._TPbautRate = (int)this.numBautRate.Value;
                clsConstant.Instance._TPDatabit = (int)this.numDataBit.Value;
                clsConstant.Instance._MCportName = this.cmbMCPort.SelectedItem.ToString();
                clsConstant.Instance._MCbautRate = (int)this.numBR.Value;
                clsConstant.Instance._MCDatabit = (int)this.numMCDB.Value;
            saveSerialPortConfig();
            DialogResult = DialogResult.OK;
        }
    }
}
