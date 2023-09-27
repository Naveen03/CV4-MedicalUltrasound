using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
namespace UTScannerApp
{
    public class clsCurve
    {
        public double[] curveXPoints;
        public double[] curveYPoints;
        public string curveName  { get;set; }
    }
    public class clsCurveList
    {
        public List<clsCurve> curveList;
    }
    public class clsConstant
    {
        public string _TPportName;
        public int _TPbautRate;
        public int _TPDatabit;

        public string _MCportName;
        public int _MCbautRate;
        public int _MCDatabit;

        public List<double[,]> allSavedData_=new List<double[,]>();     

        public List<string> allPatientDir_;
        public string selectedPatientImage_;
        public string selectedPatientDir_;
        public string paientName;
        public string hospitalName;
        public string patientID;

        public string localFolderPath;
        public string serialPortConfigFile;
        public string gammaCurveFile;
        public string CurrentCurveName;
        public bool isInlineProcess;
        public double sampleFreq_;
        public double maxDepth_;
        public double apertureSize_;
        public int probeType;
        public bool isPatientInfoOpen;
        public bool isTGCOpen;

        private static clsConstant _Instance;

        public static clsConstant Instance
        {
            get
            {
                if (_Instance == null)
                    _Instance = new clsConstant();
                return _Instance;
            }
        }
        clsConstant()
        {
            localFolderPath = System.Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
            serialPortConfigFile = localFolderPath + "\\" + "hardwareConfig.xml"; 
            this.gammaCurveFile = localFolderPath + "\\" + "Config.json"; 
        }
    }
}
