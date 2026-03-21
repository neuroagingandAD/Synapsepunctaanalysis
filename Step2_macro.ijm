// STEP 2 – Analyse puncta in the user-drawn selection, and export feret for density analysis

//Choose input and output folder  
#@ File(label = "ROIs Folder", style = "directory") input 
#@ File(label = "Output Results Folder", style = "directory") output
 
processFolder(input, output); 

// --------- Scan folders/subfolders --------- // 
function processFolder(input, output) {  
    list = getFileList(input);  
    list = Array.sort(list);  

    for (i = 0; i < list.length; i++) { 
        name = list[i]; 
        path = input + File.separator + name; 
        if (File.isDirectory(path)) { 
      
       processFolder(path, output); 
        } else { 

        processFile(input, output, name); 
        } 
    } 
// save Log and global Summary if present 
    if (isOpen("Log")) { 
    selectWindow("Log"); 
    save(output + File.separator + "Log.txt"); 
    } 
    
    if (isOpen("Summary")) { 
    selectWindow("Summary"); 
    saveAs("Results", output + File.separator + "Colocs.csv"); 
    } 
   
   //cleanup 
    run("Close All"); 
} 

// --------- Process individual files --------- // 
function processFile(input, output, fileName) { 
 	fullPath = input + File.separator + fileName; 
    open(fullPath);
    print("Processing file: " + fullPath);  


  // Choose LUT colors that help you better visualizesee better the puncta 
  	 lutOrder = newArray("Green", "Magenta", "Magenta", "Magenta"); 
   	getDimensions(width, height, channels, slices, frames); 
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

	setTool("zoom");
    waitForUser("Adjust brightness; zoom in puncta for comDET analysis, then click OK."); 
  // Run ComDet analysis; in Summary table choose append(not reset)
    run("Detect Particles"); 
   
    a = getInfo("image.filename");
    if (isOpen("Results")) { 
    selectWindow("Results"); 
    saveAs("Results", output + File.separator + a + "_Results.csv");
    } 
   
      close("\\Others");
   } 
        
    run("Close All");
