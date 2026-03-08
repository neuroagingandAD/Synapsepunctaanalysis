// STEP 1 – Create crops from raw .czi images and save them as .tif 

// Choose input and output folder  
#@ File(label = "Input Folder", style = "directory") input 
#@ File(label = "Output Image Folder", style = "directory") output
#@ File(label = "Feret Folder", style = "directory") feret

processFolder(input, output, feret); 

// --------- Scan folders/subfolders --------- // 
function processFolder(input, output, feret) { 
    list = getFileList(input); 
    list = Array.sort(list); 

    for (i = 0; i < list.length; i++) { 
        name = list[i]; 
        path = input + File.separator + name; 
        if (File.isDirectory(path)) { 

  // Recurse into subfolder 
     processFolder(path, output); 
        } else { 
        	
  // Process individual file 
     processFile(input, output, feret, name); 
        } 
    } 
} 

// --------- Process one file --------- // 
function processFile(input, output,feret, fileName) {
 
fullPath = input + File.separator + fileName;

run("Bio-Formats Importer", "open=[" + fullPath + "] autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"); 
print("Processing file: " + fullPath); 

  // Adjust LUTs and Brightness/contrast per channel 
    getDimensions(width, height, channels, slices, frames); 
    lutOrder = newArray("Green", "Magenta", "Magenta", "Magenta"); 
    nLUT = lengthOf(lutOrder); 
    for (c = 1; c <= channels; c++) { 
    Stack.setChannel(c); 
    if (c <= nLUT) run(lutOrder[c - 1]); 
  	
  	run("Brightness/Contrast..."); 
    run("Enhance Contrast...", "saturated=0.35 normalize"); 
    } 
    
    run("Channels Tool..."); 
    Property.set("CompositeProjection", "null"); 
    Stack.setDisplayMode("color"); 

  // Optional: background subtraction
  // run("Subtract Background...", "rolling=50 stack"); 
  // saveAs("Tiff", output + File.separator + fileName + "_bgsubtract.tif"); 
  
waitForUser("Check first if you want to analyse this image");

  // Ask: do you want to analyse? If not, just close and return. 

    run("ROI Manager...");
    roiCounter = 1;
    
    
    while (true) { 
        answer = getBoolean("Do you want to select a ROI in this image?"); 
        if (!answer) break; 
 
        setTool("polygon"); 
        waitForUser("Select a neuronal segment, then click OK."); 
		run("Add to Manager");
		
        // Save crop 
        base = fileName; 
    	base = replace(base, ".czi", ""); 
        saveAs("Tiff", output + File.separator + base + "_ROI_" + roiCounter + ".tif"); 
	roiCounter++;
    } 

 
    // Close raw image before returning 

run("Set Measurements...", "area mean feret's display redirect=None decimal=4");
run("Measure");
saveAs("Results", feret + File.separator + "feret.csv");

      close("\\Others");
      
    } 
    
    run("Close All");
