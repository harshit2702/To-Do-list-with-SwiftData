//
//  PKCanvasViewWrapper.swift
//  To Do list with SwiftData
//
//  Created by Harshit Agarwal on 30/12/23.
//

import SwiftUI
import PencilKit

struct PKCanvasViewWrapper: UIViewRepresentable {
    private let canvasView = PKCanvasView()
    @Binding var drawing: PKDrawing
    @Binding var showToolPicker: Bool
    let saveAction: (PKDrawing) -> Void

    init(drawing: Binding<PKDrawing>, showToolPicker: Binding<Bool>, saveAction: @escaping (PKDrawing) -> Void) {
        self._drawing = drawing
        self._showToolPicker = showToolPicker
        self.saveAction = saveAction
        canvasView.maximumZoomScale = 8.0
    }

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 10)
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        context.coordinator.toolPicker.setVisible(showToolPicker, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver, UIPencilInteractionDelegate {
        let parent: PKCanvasViewWrapper
        let toolPicker = PKToolPicker()

        init(_ canvasViewWrapper: PKCanvasViewWrapper) {
            self.parent = canvasViewWrapper
            super.init()
            
            toolPicker.addObserver(parent.canvasView)
            toolPicker.addObserver(self)
            toolPicker.setVisible(false, forFirstResponder: parent.canvasView)
            parent.canvasView.becomeFirstResponder()
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
            
            // Save action if needed
            if let saveAction = parent.saveAction as ((PKDrawing) -> Void)? {
                saveAction(canvasView.drawing)
            }
        }
        
        private func setPencilInteraction() {
            let pencilInteraction = UIPencilInteraction()
            pencilInteraction.delegate = self
            parent.canvasView.addInteraction(pencilInteraction)
        }
        
    }
}

