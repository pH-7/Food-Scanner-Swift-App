import Foundation
import GPUImage

enum FilterSliderSetting {
    case Disabled
    case Enabled(minimumValue:Float, maximumValue:Float, initialValue:Float)
}

#if os(iOS)
typealias FilterSetupFunction = (camera:GPUImageVideoCamera, outputView:GPUImageView) -> (filter:GPUImageOutput, secondOutput:GPUImageOutput?)
#else
typealias FilterSetupFunction = (camera:GPUImageAVCamera, outputView:GPUImageView) -> (filter:GPUImageOutput, secondOutput:GPUImageOutput?)
#endif

enum FilterOperationType {
    case SingleInput
    case Blend
    case Custom(filterSetupFunction:FilterSetupFunction)
}

protocol FilterOperationInterface {
    var filter: GPUImageOutput { get }
    var listName: String { get }
    var titleName: String { get }
    var sliderConfiguration: FilterSliderSetting  { get }
    var filterOperationType: FilterOperationType  { get }

    func configureCustomFilter(input:(filter:GPUImageOutput, secondInput:GPUImageOutput?))
    func updateBasedOnSliderValue(sliderValue:CGFloat)
}

class FilterOperation<FilterClass: GPUImageOutput where FilterClass: GPUImageInput>: FilterOperationInterface {
    var internalFilter: FilterClass?
    var secondInput: GPUImageOutput?
    let listName: String
    let titleName: String
    let sliderConfiguration: FilterSliderSetting
    let filterOperationType: FilterOperationType
    let sliderUpdateCallback: ((filter:FilterClass, sliderValue:CGFloat) -> ())?
    init(listName: String, titleName: String, sliderConfiguration: FilterSliderSetting, sliderUpdateCallback:((filter:FilterClass, sliderValue:CGFloat) -> ())?, filterOperationType: FilterOperationType) {
        self.listName = listName
        self.titleName = titleName
        self.sliderConfiguration = sliderConfiguration
        self.filterOperationType = filterOperationType
        self.sliderUpdateCallback = sliderUpdateCallback
        switch (filterOperationType) {
            case .Custom:
                break
            default:
                self.internalFilter = FilterClass()
        }
    }

    var filter: GPUImageOutput {
        return internalFilter!
    }

    func configureCustomFilter(input:(filter:GPUImageOutput, secondInput:GPUImageOutput?)) {
        self.internalFilter = (input.filter as! FilterClass)
        self.secondInput = input.secondInput
    }

    func updateBasedOnSliderValue(sliderValue:CGFloat) {
        if let updateFunction = sliderUpdateCallback
        {
            updateFunction(filter:internalFilter!, sliderValue:sliderValue)
        }
    }
}