////
////  VoiceConverter.swift
////  UIMaster
////
////  Created by hobson on 2019/2/13.
////  Copyright © 2019 one2much. All rights reserved.
////
//
//import UIKit
//
//class VoiceConverter: NSObject {
//    /**
//     Convert AMR file to WAV file
//     
//     - parameter amrFilePath: Your AMR file path
//     - parameter wavSavePath: Your WAV save path
//     
//     - returns: Convert success?
//     */
//    public class func convertAmrToWav(_ amrFilePath: String, wavSavePath: String) -> Bool {
//        guard let amrCString = amrFilePath.cString(using: String.Encoding.utf8) else { return false }
//        guard let wavCString = wavSavePath.cString(using: String.Encoding.utf8) else { return false }
//        let decode = DecodeAMRFileToWAVEFile(amrCString, wavCString)
//        return Bool(decode)
//    }
//    
//    /**
//     Convert WAV file to AMR file
//     
//     - parameter wavSavePath: Your WAV file path
//     - parameter amrFilePath: Your AMR save path
//     
//     - returns: Convert success?
//     */
//    public class func convertWavToAmr(_ wavFilePath: String, amrSavePath: String) -> Bool {
//        guard let wavCString = wavFilePath.cString(using: String.Encoding.utf8) else { return false }
//        guard let amrCString = amrSavePath.cString(using: String.Encoding.utf8) else { return false }
//        let encode = EncodeWAVEFileToAMRFile(wavCString, amrCString, 1, 16)
//        return Bool(encode)
//    }
//    
//    /**
//     Detect whether the file is AMR type
//     
//     - parameter filePath: The file path
//     
//     - returns: True of false
//     */
//    public class func isAMRFile(_ filePath: String) -> Bool {
//        let result = String.init(filePath)
//        return isAMRFile(result)
//    }
//    
//    /**
//     Detect whether the file is MP3 type
//     
//     - parameter filePath: The file path
//     
//     - returns: True of false
//     */
//    public class func isMP3File(_ filePath: String) -> Bool {
//        let result = String.init(filePath)
//        return isMP3File(result)
//    }
//    
//    // 将AMR文件解码成WAVE文件
//    public DecodeAMRFileToWAVEFile(pchAMRFileName:[CChar],pchWAVEFilename:[CChar]){
//    
//    
//    FILE* fpamr = NULL;
//    FILE* fpwave = NULL;
//    char magic[8];
//    void * destate;
//    int nFrameCount = 0;
//    int stdFrameSize;
//    unsigned char stdFrameHeader;
//    
//    unsigned char amrFrame[MAX_AMR_FRAME_SIZE];
//    short pcmFrame[PCM_FRAME_SIZE];
//    
//    //    NSString * path = [[NSBundle mainBundle] pathForResource:  @"test" ofType: @"amr"];
//    //    fpamr = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "rb");
//    fpamr = fopen(pchAMRFileName, "rb");
//    
//    if ( fpamr==NULL ) return 0;
//    
//    // 检查amr文件头
//    fread(magic, sizeof(char), strlen(AMR_MAGIC_NUMBER), fpamr);
//    if (strncmp(magic, AMR_MAGIC_NUMBER, strlen(AMR_MAGIC_NUMBER)))
//    {
//    fclose(fpamr);
//    return 0;
//    }
//    
//    // 创建并初始化WAVE文件
//    //    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //    NSString *documentPath       = [paths objectAtIndex:0];
//    //    NSString *docFilePath        = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%s", pchWAVEFilename]];
//    //    DLog(@"documentPath=%@", documentPath);
//    //
//    //    fpwave = fopen([docFilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
//    fpwave = fopen(pchWAVEFilename,"wb");
//    
//    WriteWAVEFileHeader(fpwave, nFrameCount);
//    
//    /* init decoder */
//    destate = Decoder_Interface_init();
//    
//    // 读第一帧 - 作为参考帧
//    memset(amrFrame, 0, sizeof(amrFrame));
//    memset(pcmFrame, 0, sizeof(pcmFrame));
//    ReadAMRFrameFirst(fpamr, amrFrame, &stdFrameSize, &stdFrameHeader);
//    
//    // 解码一个AMR音频帧成PCM数据
//    Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
//    nFrameCount++;
//    fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
//    
//    // 逐帧解码AMR并写到WAVE文件里
//    while(1)
//    {
//    memset(amrFrame, 0, sizeof(amrFrame));
//    memset(pcmFrame, 0, sizeof(pcmFrame));
//    if (!ReadAMRFrame(fpamr, amrFrame, stdFrameSize, stdFrameHeader)) break;
//    
//    // 解码一个AMR音频帧成PCM数据 (8k-16b-单声道)
//    Decoder_Interface_Decode(destate, amrFrame, pcmFrame, 0);
//    nFrameCount++;
//    fwrite(pcmFrame, sizeof(short), PCM_FRAME_SIZE, fpwave);
//    }
//    //    DLog(@"frame = %d", nFrameCount);
//    Decoder_Interface_exit(destate);
//    
//    fclose(fpwave);
//    
//    // 重写WAVE文件头
//    //    fpwave = fopen([docFilePath cStringUsingEncoding:NSASCIIStringEncoding], "r+");
//    fpwave = fopen(pchWAVEFilename, "r+");
//    WriteWAVEFileHeader(fpwave, nFrameCount);
//    fclose(fpwave);
//    
//    return nFrameCount;
//    }
//}
//
//private extension Bool {
//    init<T : BinaryInteger>(_ integer: T){
//        self.init(integer != 0)
//    }
//}
