const asyncHandler = require('express-async-handler');
const Jobs = require('../Model/JobsModel');
const Projects = require("../Model/ProjectsModel");
const cloudinary = require('../Config/cloudinary');
const mongoose =require("mongoose")

cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

const jobCreate = asyncHandler(async (req, res) => {
  const {
    projectsId, 
    brandName,
    subBrand,
    flavour,
    packType,
    packSize,
    priority,
    Status,
    assign,
    totalTime,
    barcode
  } = req.body;

  try {
    const project = await Projects.findById(projectsId);
    if (!mongoose.Types.ObjectId.isValid(projectsId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format"
      });
    }
    
    const newJob = new Jobs({
      projects: projectsId,
      brandName,
      subBrand,
      flavour,
      packType,
      packSize,
      priority,
      Status,
      assign,
      totalTime,
      barcode
    });
    await newJob.save();
    const jobData = newJob.toObject();
    jobData.projectId = jobData.projects;
    delete jobData.projects; 
    res.status(201).json({
      success: true,
      message: "Job created successfully",
      job: jobData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Job",
      error: error.message,
    });
  }
});


    //GET SINGLE AllProjects
  //METHOD:GET
  const AllJob = async (req, res) => {
    try {
      // Fetch all jobs and populate the related project data (_id and projectName)
      const allJobs = await Jobs.find()
        .populate('projects', '_id projectName'); // Populate project fields: _id and projectName
  
      if (!allJobs || allJobs.length === 0) {
        return res.status(404).json({ success: false, message: "No jobs found" });
      }
  
      res.status(200).json({
        success: true,
        jobs: allJobs, // Return all jobs with populated project data
      });
  
    } catch (error) {
      console.error("Error fetching jobs:", error);
      res.status(500).json({
        success: false,
        message: "An error occurred while fetching jobs",
        error: error.message,
      });
    }
};

  
  
  
  
  


  //GET SINGLE DeleteProjects
  //METHOD:DELETE
  const deleteJob = async (req, res) => {
      let deleteJobID = req.params.id
      if (deleteJob) {
        const deleteJob = await Jobs.findByIdAndDelete(deleteJobID, req.body);
        res.status(200).json("Delete Job Successfully")
      } else {
        res.status(400).json({ message: "Not Delete project" })
      }
    }
    
  
    //GET SINGLE ProjectsUpdate
  //METHOD:PUT
  const UpdateJob = async (req, res) => {
    try {
      const allowedFields = [
        'projects',  // Project ID
        'projectName',     
        'brandName',
        'subBrand',    
        'flavour',    
        'packType',
        'packSize',
        'priority',
        'Status',
        'assign',
        'totalTime',
      ];
      const updateData = {};
      allowedFields.forEach(field => {
        if (req.body[field] !== undefined) {
          updateData[field] = req.body[field];
        }
      });

      if (Object.keys(updateData).length === 0) {
        return res.status(400).json({ message: 'At least one field must be provided for update' });
      }
      const updatedDiary = await Jobs.findByIdAndUpdate(
        req.params.id,
        updateData,
        { new: true }
      );
      if (!updatedDiary) {
        return res.status(404).json({ message: 'Diary not found' });
      }
      res.status(200).json(updatedDiary);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error', error });
    }
  };




  
  //METHOD:Single
  //TYPE:PUBLIC
    const SingleJob=async(req,res)=>{
      try {
          const SingleJob= await Jobs.findById(req.params.id);
          res.status(200).json(SingleJob)
      } catch (error) {
          res.status(404).json({msg:"Can t Find Diaries"} )
      }
  }


module.exports = {jobCreate,AllJob,deleteJob,UpdateJob,SingleJob};
























const asyncHandler = require('express-async-handler');
const Jobs = require('../Model/JobsModel');
const Projects = require("../Model/ProjectsModel");
const cloudinary = require('../Config/cloudinary');
const mongoose =require("mongoose")

cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});
const jobCreate = asyncHandler(async (req, res) => {
  const {
    projectsId, 
    brandName,
    subBrand,
    flavour,
    packType,
    packSize,
    priority,
    Status,
    assign,
    totalTime,
    barcode
  } = req.body;

  try {
    // Check if the Project ID is valid
    if (!mongoose.Types.ObjectId.isValid(projectsId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format"
      });
    }
    
    // Find the Project to verify it exists
    const project = await Projects.findById(projectsId);
    if (!project) {
      return res.status(404).json({
        success: false,
        message: "Project not found"
      });
    }

    // Create a new Job with the correct field name projectId
    const newJob = new Jobs({
      projectId: projectsId, // Fixing this to use projectId
      brandName,
      subBrand,
      flavour,
      packType,
      packSize,
      priority,
      Status,
      assign,
      totalTime,
      barcode
    });

    // Save the job
    await newJob.save();

    // Format the job data to include projectId instead of projects
    const jobData = newJob.toObject();
    jobData.projectId = jobData.projectId; // Ensure projectId is returned
    delete jobData.projects; // Remove the old field if it exists
    
    res.status(201).json({
      success: true,
      message: "Job created successfully",
      job: jobData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Job",
      error: error.message,
    });
  }
});




    //GET SINGLE AllProjects
  //METHOD:GET
  const AllJob = async (req, res) => {
    try {
      const allJobs = await Jobs.find()
        .populate({
          path: 'projectId', // Use projectId to populate
          select: '_id name', // Include both project ID and name
          model: 'Projects'
        });
  
      if (!allJobs || allJobs.length === 0) {
        return res.status(404).json({ success: false, message: "No jobs found" });
      }
  
      // Modify the response to include projectId and projectName
      const jobsWithProjectDetails = allJobs.map(job => {
        return {
          ...job.toObject(),
          project: {
            projectId: job.projectId._id, // project ID
            projectName: job.projectId.name, // project name
          }
        };
      });
  
      res.status(200).json({
        success: true,
        jobs: jobsWithProjectDetails,
      });
  
    } catch (error) {
      console.error("Error fetching jobs:", error);
      res.status(500).json({
        success: false,
        message: "An error occurred while fetching jobs",
        error: error.message,
      });
    }
  };
  
  
  
  
  


  //GET SINGLE DeleteProjects
  //METHOD:DELETE
  const deleteJob = async (req, res) => {
      let deleteJobID = req.params.id
      if (deleteJob) {
        const deleteJob = await Jobs.findByIdAndDelete(deleteJobID, req.body);
        res.status(200).json("Delete Job Successfully")
      } else {
        res.status(400).json({ message: "Not Delete project" })
      }
    }
    
  
    //GET SINGLE ProjectsUpdate
  //METHOD:PUT
  const UpdateJob = async (req, res) => {
    try {
      const allowedFields = [
        'projects',  // Project ID
        'projectName',     
        'brandName',
        'subBrand',    
        'flavour',    
        'packType',
        'packSize',
        'priority',
        'Status',
        'assign',
        'totalTime',
      ];
      const updateData = {};
      allowedFields.forEach(field => {
        if (req.body[field] !== undefined) {
          updateData[field] = req.body[field];
        }
      });

      if (Object.keys(updateData).length === 0) {
        return res.status(400).json({ message: 'At least one field must be provided for update' });
      }
      const updatedDiary = await Jobs.findByIdAndUpdate(
        req.params.id,
        updateData,
        { new: true }
      );
      if (!updatedDiary) {
        return res.status(404).json({ message: 'Diary not found' });
      }
      res.status(200).json(updatedDiary);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error', error });
    }
  };




  
  //METHOD:Single
  //TYPE:PUBLIC
    const SingleJob=async(req,res)=>{
      try {
          const SingleJob= await Jobs.findById(req.params.id);
          res.status(200).json(SingleJob)
      } catch (error) {
          res.status(404).json({msg:"Can t Find Diaries"} )
      }
  }


module.exports = {jobCreate,AllJob,deleteJob,UpdateJob,SingleJob};





const mongoose = require("mongoose");

const Projects = require("./ProjectsModel");

const jobsSchema = new mongoose.Schema({
    projectId:[ {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Projects',
        required: true,
    }],
    brandName: {
        type:String ,
        required: true,
    },
    subBrand: {
        type: String,
        required: true,
    },
    flavour: {
        type: String,
        required: true,
    },
    packType: {
        type: String,
        required: true,
    },
    packSize: {
        type: String,
        required: true,
    },
    priority:{
        type: String,
        required: true,
    },
    Status: {
        type: String,
        required: true,
    },
    assign: {
        type: String,
        required: true,
    },
    barcode: {
        type: String,
        required: true
      },
    totalTime: {
        type: String,
        require: true
    }
},{
    timestamps: true,
});

module.exports = mongoose.model('Jobs', jobsSchema);






























  const AllJob = async (req, res) => {
    try {
      // Fetch all projects with their _id and projectName
      const allProjects = await Projects.find()
        .select('_id projectName'); // Only select _id and projectName fields
  
      if (!allProjects || allProjects.length === 0) {
        return res.status(404).json({ success: false, message: "No projects found" });
      }
  
      res.status(200).json({
        success: true,
        jobs: allProjects, // Return the projects in the response
      });
  
    } catch (error) {
      console.error("Error fetching projects:", error);
      res.status(500).json({
        success: false,
        message: "An error occurred while fetching projects",
        error: error.message,
      });
    }
  };
  



  {
    "projectsId": [
      "681c8656d90e15caa3863398", 
      "681c8662d90e15caa386339a"
    ],
    "brandName": "Pepsi",
    "subBrand": "Pepsi Max",
    "flavour": "Cherry",
    "packType": "Can",
    "packSize": "330ml",
    "priority": "Low",
    "Status": "In Progress",
    "assign": "Designer",
    "barcode": "POS-123456",
    "totalTime": "05:30"
  }
  

























  // //////////////
  
// ///////////////////


const userRegister=asynchandler(
async(req,res)=>{
    const {name,email,phone,address,city,password}=req.body

    if(!name || !email || !phone || !address || !city || !password ){
        throw new Error("Pliss Fill All Detilse")
    }
     if(phone.length > 10){
        res.status(401)
        throw new Error('Please number is 10 digit')    
     }
    // user Exist 
     const userExist = await User.findOne({email:email})

    if(userExist){
    res.status(401)
    throw new Error("User Already Exist")
    }

     const salt = await bcrypt.genSalt(10)
     const hashpassword =await bcrypt.hash(password,salt)

    //  creat 
    const user = await User.create({
        name,
        email,
        phone,
        address,
        city,
        password:hashpassword,
    })
    if(user){
        res.status(201).json({
            _id:user._id,
            name:user.name,
            email:user.email,
            phone:user.phone,
            address:user.address,
            city:user.city,
            password:user.password,
            token:genretToken(user._id)

        })
    } 
 
    res.send("Register Router")
})

const userlogin=asynchandler(
async(req,res)=>{
    const {email,password}=req.body
    if(!email || !password){
        throw new Error("Pliss Fill All Detilse")
    }

    //  user Exist 
    const  user =await User.findOne({email})

    if(user && (await bcrypt.compare(password,user.password))){
     res.status(200).json({
        _id:user._id,
        email:user.email,
        password:user.password,
        isAdmin : user?.isAdmin,
        token:genretToken(user._id),
        

     })
    }else{
        res.status(401)
        throw new Error("Invalid Cordetion")
    }

    res.send("Login Router")
})



module.exports = {userRegister,userlogin,getMe}

























const asyncHandler = require('express-async-handler');
const ReceivablePurchase = require('../Model/ReceivablePurchaseModel');
const Projects = require("../Model/ProjectsModel");
const ClientManagement = require("../Model/ClientManagementModel");
const cloudinary = require('../Config/cloudinary');
const mongoose = require("mongoose");

cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

const ReceivablePurchaseCreate = asyncHandler(async (req, res) => {
  let {
    projectsId,
    ClientId,
    Status,
    ReceivedDate,
    Amount
  } = req.body;

  try {
    if (typeof projectsId === "string") {
      try {
        projectsId = JSON.parse(projectsId);
      } catch (err) {
        return res.status(400).json({
          success: false,
          message: "Invalid projectsId format",
        });
      }
    }

    if (!projectsId || !Array.isArray(projectsId)) {
      return res.status(400).json({
        success: false,
        message: "projectsId is required and should be an array"
      });
    }

    const projects = await Projects.find({ _id: { $in: projectsId } });
    if (projects.length !== projectsId.length) {
      return res.status(404).json({
        success: false,
        message: "One or more projects not found."
      });
    }

    const client = await ClientManagement.findById(ClientId);
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client not found."
      });
    }

    let imageUrls = [];

    if (req.files && req.files.image) {
      const files = Array.isArray(req.files.image) ? req.files.image : [req.files.image];

      for (const file of files) {
        try {
          const result = await cloudinary.uploader.upload(file.tempFilePath, {
            folder: 'user_profiles',
            resource_type: 'image',
          });
          if (result.secure_url) {
            imageUrls.push(result.secure_url);
          }
        } catch (uploadError) {
          console.error("Cloudinary upload error:", uploadError);
        }
      }
    }

    const newReceivablePurchase = new ReceivablePurchase({
      projectsId,
      ClientId,
      ReceivedDate,
      Status,
      Amount,
      image: imageUrls, 
    });

    await newReceivablePurchase.save();

    res.status(201).json({
      success: true,
      message: "Receivable Purchase created successfully",
      receivablePurchase: newReceivablePurchase,
    });

  } catch (error) {
    console.error("Error creating Receivable Purchase:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Receivable Purchase",
      error: error.message,
    });
  }
});


module.exports = { ReceivablePurchaseCreate };




















































function convertTo24Hour(timeStr) {
  const [time, modifier] = timeStr.trim().split(" ");
  let [hours, minutes] = time.split(":").map(Number);

  if (modifier.toUpperCase() === "PM" && hours !== 12) {
    hours += 12;
  } else if (modifier.toUpperCase() === "AM" && hours === 12) {
    hours = 0;
  }

  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
}


const TimesheetWorklogCreate = asyncHandler(async (req, res) => {
  const {
    projectId,
    jobId,
    employeeId,
    date,
    startTime,
    endTime,
    taskDescription,
    status,
    tags
  } = req.body;

  try {
    // Validate project IDs
    if (!Array.isArray(projectId) || projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format. Ensure all IDs are valid."
      });
    }

    // Validate jobId array
    if (!Array.isArray(jobId) || jobId.length === 0 || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Job ID format. Ensure all IDs are valid."
      });
    }

    // Validate EmployeeId array
    // ✅ Validate Employee ID array
    if (!Array.isArray(employeeId) || employeeId.length === 0 || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Employee ID format. Ensure all IDs are valid."
      });
    }

    // Check if all projects exist
    const projects = await Projects.find({ '_id': { $in: projectId } });
    if (projects.length !== projectId.length) {
      return res.status(404).json({
        success: false,
        message: "One or more projects not found"
      });
    }

    // Check if job exists (using first jobId only)
    const job = await Jobs.findById(jobId[0]);
    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found"
      });
    }
    // Check if job exists (using first jobId only)

    // Validate EmployeeId array
    // ✅ Find employee in User table
    const employeeUser = await User.findOne({ _id: employeeId[0], role: "employee" });
    if (!employeeUser) {
      return res.status(404).json({
        success: false,
        message: "Employee user not found or role is not 'employee'"
      });
    }

    // Convert to 24-hour format
    const start24 = convertTo24Hour(startTime);
    const end24 = convertTo24Hour(endTime);

    // Validate and calculate hours
    const start = new Date(`${date}T${start24}`);
    const end = new Date(`${date}T${end24}`);


    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid startTime or endTime format"
      });
    }

    // ✅ Handle overnight shift
    if (start >= end) {
      end.setDate(end.getDate() + 1); // Add 1 day to end
    }

    const milliseconds = end - start;
    const totalMinutes = Math.floor(milliseconds / (1000 * 60));
    const hours = +(totalMinutes / 60).toFixed(2);
    const durationReadable = `${Math.floor(totalMinutes / 60)}:${String(totalMinutes % 60).padStart(2, '0')}`;

    // Create the new TimeLog
    const newTimesheetWorklog = new TimesheetWorklogs({
      projectId,
      jobId: jobId[0],
      employeeId: employeeUser._id,
      date,
      startTime,
      endTime,
      hours: durationReadable,
      taskDescription,
      status,
      tags
    });

    await newTimesheetWorklog.save();

    res.status(201).json({
      success: true,
      message: "TimeLog created successfully",
      TimesheetWorklog: newTimesheetWorklog.toObject(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the TimeLog",
      error: error.message,
    });
  }
});



















// const TimesheetWorklogCreate = asyncHandler(async (req, res) => {

//     const {
//         projectId,
//         jobId,
//         date,
//         startTime,
//         endTime,
//         hours,
//         taskDescription,
//         status,
//         tags
//     } = req.body;

//     try {
//         // Validate project IDs
//         if (!Array.isArray(projectId) || projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//             return res.status(400).json({
//                 success: false,
//                 message: "Invalid Project ID format. Ensure all IDs are valid."
//             });
//         }

//         // Validate jobId array
//         if (!Array.isArray(jobId) || jobId.length === 0 || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//             return res.status(400).json({
//                 success: false,
//                 message: "Invalid Job ID format. Ensure all IDs are valid."
//             });
//         }

//         // Check if all projects exist
//         const projects = await Projects.find({ '_id': { $in: projectId } });
//         if (projects.length !== projectId.length) {
//             return res.status(404).json({
//                 success: false,
//                 message: "One or more projects not found"
//             });
//         }

//         // Check if job exists (using first jobId only)
//         const job = await Jobs.findById(jobId[0]);
//         if (!job) {
//             return res.status(404).json({
//                 success: false,
//                 message: "Job not found"
//             });
//         }

//         // Create the new TimeLog
//         const newTimesheetWorklog = new TimesheetWorklogs({
//             projectId: projectId,
//             jobId: jobId[0],  
//             date,
//             startTime,
//             endTime,
//             hours,
//             taskDescription,
//             status,
//             tags
//         });

//         await newTimesheetWorklog.save();

//         res.status(201).json({
//             success: true,
//             message: "TimeLog created successfully",
//             TimesheetWorklog: newTimesheetWorklog.toObject(),
//         });
//     } catch (error) {
//         res.status(500).json({
//             success: false,
//             message: "An error occurred while creating the TimeLog",
//             error: error.message,
//         });
//     }
// });

// Helper: Convert 12-hour format (e.g., "02:30 PM") to 24-hour format (e.g., "14:30")

























const asyncHandler = require('express-async-handler');
const CostEstimates = require('../../Model/Admin/CostEstimatesModel');
const Projects = require("../../Model/Admin/ProjectsModel");
const ClientManagement = require("../../Model/Admin/ClientManagementModel");
const cloudinary = require('../../Config/cloudinary');

const mongoose = require("mongoose");

cloudinary.config({
  cloud_name: 'dkqcqrrbp',
  api_key: '418838712271323',
  api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});
const costEstimatesCreate = asyncHandler(async (req, res) => {
  const {
    projectsId,
    clientId,
    estimateDate,
    validUntil,
    currency,
    lineItems,
    VATRate,
    Notes,
    POStatus,
    Status
  } = req.body;

  try {
if (!Array.isArray(projectsId) || projectsId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
  return res.status(400).json({ success: false, message: "Invalid Project ID format." });
}


    if (!mongoose.Types.ObjectId.isValid(clientId)) {
      return res.status(400).json({ success: false, message: "Invalid Client ID format." });
    }

    const projects = await Projects.find({ '_id': { $in: projectsId } });
    if (projects.length !== projectsId.length) {
      return res.status(404).json({ success: false, message: "One or more projects not found" });
    }

    const client = await ClientManagement.findById(clientId);
    if (!client) {
      return res.status(404).json({ success: false, message: "Client not found" });
    }

    const newCostEstimate = new CostEstimates({
      projectId: projectsId,
      clientId,
      estimateDate,
      validUntil,
      currency,
      lineItems,
      VATRate,
      Notes,
      POStatus,
      Status,
      estimateRef 
    });

    await newCostEstimate.save();

    res.status(201).json({
      success: true,
      message: "Cost Estimate created successfully",
      costEstimate: newCostEstimate,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Cost Estimate",
      error: error.message,
    });
  }
});
