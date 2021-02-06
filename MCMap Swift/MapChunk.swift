//
//  MapChunk.swift
//  MCMap Swift
//
//  Created by C.W. Betts on 2/5/21.
//

import Cocoa

private func getBaseLod(_ zoom: Float) -> Int {
	if zoom > 32 {
		return 5;
	} else if zoom > 16 {
		return 4;
	} else if zoom > 8 {
		return 3;
	} else if zoom > 4 {
		return 2;
	} else if zoom > 2 {
		return 1;
	} else {
		return 0;
	}
}


final class MapChunk {
	enum RendererStatus: Int32 {
		case needsRunning = 0
		case running = 1
		case done = 2
	}
	
	private var x: Int
	private var y: Int
	
	/// The texture has been rendered and is on the disk
	private var onDisk = false
	
	/// The texture is totally blank and need not be rendered
	private(set) var isBlank = false;
	
	/// The texture is totally blank and need not be rendered
	private var blankChecked = false
	
	
	private var renderer: Process? = nil;
	private var needsRender = true;
	private var invalid = false;
	
	private let fileName: String

	var renderSettings: [String] = []
	/*
	GLuint texture[6];
	*/
	
	init(x: Int, y: Int) {
		self.x = x
		self.y = y
		
		fileName = ((NSTemporaryDirectory() as NSString).appendingPathComponent("MCMap Swift") as NSString).appendingPathComponent("chunk_\(x)_\(y).png")
	}
	
	deinit {
		deleteAllTextures()
	}
	
	/// Create the NSTask needed to render this block's texture and launch it.
	func startRenderer() {
		if (!onDisk && renderer == nil) {
			needsRender = false;
			// Now we should fire off an event to render the chunk we need.
			// Make a new NSTask and throw it on the renderers dictionary.
			let renderer = Process()
			self.renderer = renderer
			
			// Tell the task where to find mcmap (it's in the resource folder of the bundle!)
			renderer.launchPath = Bundle.main.path(forResource: "mcmap", ofType: nil)
			
			var theseSettings = renderSettings
			theseSettings.append("-from")
			theseSettings.append("\(x)")
			theseSettings.append("\(y)")
			theseSettings.append("-to")
			theseSettings.append("\(x+7)")
			theseSettings.append("\(y+7)")
			theseSettings.append("-png")
			theseSettings.append("-file")
			theseSettings.append(fileName)
			
			// Setup the renderer
			renderer.arguments = theseSettings
			
			renderer.terminationHandler = { [self] (proc: Process) -> Void in
				if proc.terminationStatus == SIGTERM || proc.terminationStatus == SIGKILL {
					return
				}
				onDisk = true
				self.renderer = nil
			}
			// And launch it
			renderer.launch()
		}
	}
	
	/// Keep everything but mark the texture as invalid. Get ready to be rendered again.
	func invalidate() {
		// Trivial case: the texture is blank
		if isBlank {
			return // Nothing to do
		}

		// Special case: the renderer is running right now
		if let renderer = self.renderer {
			renderer.terminate()
			self.renderer = nil
		}
		
		// Put the object in a state where it will re-render.
		onDisk = false
		needsRender = true
		invalid = true // Lets the draw code know to use only VRAM
					   // (and reset VRAM once the texture is available on disk)
	}
	
	/// Remove all the textures from VRAM
	func deleteAllTextures() {
		
	}
	
	func checkRenderer() -> RendererStatus {
		if needsRender {
			return .needsRunning
		} else if renderer != nil {
			return .running
		} else {
			return .done
		}
	}
	
	/// Delete the textures out of memory and act like a new, unrendered chunk.
	func reset() {
		// It's far easier to invalidate the texture before reset, since that code
		// knows how to deal with the mid-render situations.
		invalidate()
		deleteAllTextures()
		onDisk = false;
		// isBlank = false; // A blank chunk is forever blank, from any angle, for any reason.
		// blankChecked = false;
		renderer = nil
		needsRender = true
		invalid = false
	}
	
	func setBlank() {
		isBlank = true
		blankChecked = true
	}
	
	/// Returns true if the chunk is visible onscreen and needs to be drawn. If isBlank, then is always false.
	func isVisible(left: Float, right: Float, top: Float, bottom: Float, zoom: Float) -> Bool {
		if isBlank {
			return false
		}
		
		// Perform real checks here eventually
		return true
		
		/*
		
		- (BOOL) blockIsVisibleX:(int)bx Y:(int)by
	{
		// Check each corner of the block and make sure its screen position
		float ul[2], ur[2], bl[2], br[2];
		float zoom = exp(zoom_level);
		float blocksize = 522;
		
		// Screen Edges
		float left = camera.viewPos.x - (0.5*camera.viewWidth+blocksize)*zoom;
		float right = camera.viewPos.x + (0.5*camera.viewWidth+blocksize)*zoom;
		float top = camera.viewPos.y + (0.5*camera.viewHeight+blocksize)*zoom;
		float bottom = camera.viewPos.y - (0.5*camera.viewHeight+blocksize)*zoom;
		
		block2screen(bx,by,ul);
		block2screen(bx+8,by,ur);
		block2screen(bx,by+8,bl);
		block2screen(bx+8,by+8,br);
		
		if (ul[0] > left && ul[0] < right && ul[1] > bottom && ul[1] < top)
			return TRUE;
		if (ur[0] > left && ur[0] < right && ur[1] > bottom && ur[1] < top)
			return TRUE;
		if (bl[0] > left && bl[0] < right && bl[1] > bottom && bl[1] < top)
			return TRUE;
		if (br[0] > left && br[0] < right && br[1] > bottom && br[1] < top)
			return TRUE;
		return FALSE;
	}
		
		*/
	}
	
	/// Remove the render from disk. This resets `onDisk`.
	private func deleteOnDisk() {
		try? FileManager.default.removeItem(atPath: fileName)
		
		onDisk = false
	}
}
