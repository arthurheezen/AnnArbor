# ParseA2TBL.py - python Parser for Ann Arbor Trial Balance Listing report
# Python 2.7

# Usage:
#   python ParseA2TBL <InputPDFFileNameNoExtension>
# Example:
#   python ParseA2TBL.py "A2 TBL 2013_01"
#   - uses input file "Reports\\A2 TBL 2013_01.pdf"

# Imports
from pdfminer.pdfparser import PDFParser
from pdfminer.pdfdocument import PDFDocument
from pdfminer.pdfpage import PDFPage
from pdfminer.pdfpage import PDFTextExtractionNotAllowed
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.pdfdevice import PDFDevice
from pdfminer.layout import LAParams
from pdfminer.converter import PDFPageAggregator
import pdfminer  # pdfminer reads input PDF report
import sqlite3   # sqlite3 database stores all temporary data
import re        # regular expressions are used to match and parse text strings
import sys       # for command line parameter retrieval
#from __future__ import print_function

def init_db(cur):
    cur.execute(open(r'SQLScripts\CREATE TABLE A2TBLIn.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2TBLTemp.sql', 'r').read())
        
def add_row(cur, pageNum, leftPoints, lowerPoints, rightPoints, upperPoints, pDFString):
    
    # Convert position measures from points to ingtegral millipoints
    leftMP   = int(round(leftPoints*1000.0))
    lowerMP  = int(round(lowerPoints*1000.0))
    rightMP  = int(round(rightPoints*1000.0))
    upperMP  = int(round(upperPoints*1000.0))
    
    # Calculate width, height and midpoints in millipoints
    widthMP  = int(round((rightPoints-leftPoints)*1000.0))
    heightMP = int(round((upperPoints-lowerPoints)*1000.0))
    hMidPtMP = (leftPoints*1000.0 + rightPoints*1000.0) / 2
    vMidPtMP = (upperPoints*1000.0 + lowerPoints*1000.0) / 2
    
    # Initialize variables
    numberScale2 = None
    columnNum = None
    accountCode = None
    accountDesc = None
    runBy = None
    runDate = None
    runTime = None
    sectionL1Code = None
    sectionL2Code = None
    groupName = None
    groupCode = None
    groupDesc = None
    grpSectTotal = None
    treatment = None
    throughDate = None
    
    # Run regex matches
    # It is inefficient to do for every piece of text, 
    #   but logic is easier...
    mNumber = pNumber.match(pDFString)
    mAccount = pAccount.match(pDFString)
    mRunBy = pRunBy.match(pDFString)
    mSectionL1Code = pSectionL1Code.match(pDFString)
    mSectionL1Totals = pSectionL1Totals.match(pDFString)
    mSectionL2Code = pSectionL2Code.match(pDFString)
    mSectionL2Totals = pSectionL2Totals.match(pDFString)
    mGroupHeader = pGroupHeader.match(pDFString)
    mGrandTotals = pGrandTotals.match(pDFString)
    mGroupTotals = pGroupTotals.match(pDFString)
    mGroupPartial = pGroupPartial.match(pDFString)
    mMiscTotals = pMiscTotals.match(pDFString)
    mColumnHeader = pColumnHeader.match(pDFString)
    mPageHeader = pPageHeader.match(pDFString)
    mThroughDate = pThroughDate.match(pDFString)
    mPageNumber = pPageNumber.match(pDFString)
    
    # Classify text and set variables before inserting in DB
    # Most frequent elements are first
    
    # Number (in body of report)
    if mNumber:
        
        # Numbers are stored as integers (numbers of cents)
        numberScale2 = ('' if mNumber.group(1) is None else '-')
        for i in range(2, 8):
            numberScale2 += '' if mNumber.group(i) is None else str(mNumber.group(i))
        numberScale2 = int(numberScale2)
        
        # Determine the column number
        columnNum = int(round((hMidPtMP - 335000) / 108000))
        treatment = 'Number:'
        
    # Account code
    elif leftMP == 20016 and mAccount:
        
        accountCode = mAccount.group(1)
        treatment = 'Account Code:'
        
    # Column Header
    elif upperMP >= 492516 and mColumnHeader:
        
        treatment = 'Column Header:'
        
    # Page Header
    elif upperMP >= 539412 and mPageHeader:
        
        treatment = 'Page Header:'
        
    # Through Date
    elif upperMP == 568356 and mThroughDate:
        
        throughDate = mThroughDate.group(1)
        treatment = 'Through Date:'
        
    # Page Number
    elif lowerMP == 20376 and mPageNumber:
        
        treatment = 'Page Number:'
        
    # Group Totals (Fund, agency, organization, activity), code and description
    elif (rightMP == 230015) and mGroupTotals:
        
        groupName = mGroupTotals.group(1)
        groupCode = mGroupTotals.group(2)
        groupDesc = mGroupTotals.group(3)
        grpSectTotal = 'Y'
        treatment = 'Group Totals:'
    
    # Group Header (Fund, agency, organization, activity, function), code and description
    elif (leftMP == 20016 or leftMP == 47016 or leftMP == 56016 or leftMP == 65016 or leftMP == 74016) and mGroupHeader:
        
        groupName = mGroupHeader.group(1)
        groupCode = mGroupHeader.group(2)
        groupDesc = mGroupHeader.group(3)
        treatment = 'Group Header:'
        
    # Run by (person, date and time)
    elif leftMP == 20016 and mRunBy:
        
        runBy = mRunBy.group(1)
        runDate = mRunBy.group(2)
        runTime = mRunBy.group(3)
        treatment = 'Run By:'
        
    # Section L1 Code
    elif mSectionL1Code:
        
        sectionL1Code = mSectionL1Code.group(1)
        treatment = 'Section L1 Code:'
        
    # Section L2 Code
    elif mSectionL2Code:
        
        sectionL2Code = mSectionL2Code.group(1)
        treatment = 'Section L2 Code:'
        
    # Section L1 Totals
    elif mSectionL1Totals:
        
        sectionL1Code = mSectionL1Totals.group(1)
        grpSectTotal = 'Y'
        treatment = 'Section L1 Totals:'
        
    # Section L2 Totals
    elif mSectionL2Totals:
        
        sectionL2Code = mSectionL2Totals.group(1)
        grpSectTotal = 'Y'
        treatment = 'Section L2 Totals:'
        
    # Grand Totals
    elif mGrandTotals:
        
        grpSectTotal = 'Y'
        treatment = 'Grand Totals:'
        
    # Group Partial
    elif mGroupPartial:
        
        groupName = mGroupPartial.group(1)
        groupCode = mGroupPartial.group(2)
        groupDesc = mGroupPartial.group(3)
        treatment = 'Group Partial:'
    
    # Misc Totals
    elif mMiscTotals:
        
        groupDesc = mMiscTotals.group(1)
        grpSectTotal = 'Y'
        treatment = 'Misc Totals:'
        
    # Account Desc
    elif leftMP == 74016:
        
        accountDesc = pDFString[0:-1]
        treatment = 'Account Desc:'
    
    # Insert parsed string into database
    cur.execute('''
       INSERT INTO A2TBLIn (
           PageNum, 
           LeftMP, 
           LowerMP, 
           RightMP, 
           UpperMP, 
           WidthMP, 
           HeightMP, 
           VCumulativeMP, 
           PDFString,
           GroupName,
           GroupCode,
           GroupDesc,
           SectionL1Code,
           SectionL2Code,
           AccountCode,
           AccountDesc,
           GrpSectTotal,
           ColumnNum,           
           NumberScale2,           
           Treatment,
           ThroughDate)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)''', (
           pageNum, 
           leftMP,
           lowerMP,
           rightMP,
           upperMP,
           widthMP,
           heightMP,
           pageNum*612000-int(round(vMidPtMP)),
           pDFString[0:-1],
           groupName,
           groupCode,
           groupDesc,
           sectionL1Code,
           sectionL2Code,
           accountCode,
           accountDesc,
           grpSectTotal,
           columnNum,
           numberScale2,
           treatment,
           throughDate ) )

def parse_obj(cur, lt_objs):

    # loop over the object list
    for obj in lt_objs:

        # if it's a textbox, record text and location
        if isinstance(obj, pdfminer.layout.LTTextLineHorizontal):
            
            add_row(cur, myPageNum, obj.bbox[0], obj.bbox[1], obj.bbox[2], obj.bbox[3], obj.get_text())

        # if it's a container, recurse
        elif isinstance(obj, pdfminer.layout.LTFigure):
            parse_obj(cur, obj._objs)

        # if it's a container, recurse
        elif isinstance(obj, pdfminer.layout.LTTextBox):
            parse_obj(cur, obj._objs)

def merge_records(cur):
    cur.executescript(open(r'SQLScripts\merged_wrapped_totals.sql', 'r').read())
    db.commit()

def update_total_records(cur):
    cur.executescript(open(r'SQLScripts\update_positions_of_total_labels.sql', 'r').read())
    db.commit()

def group_sect_limits(cur):
    
    # Get limits of labels to be applied
    cur.execute(open(r'SQLScripts\CREATE TABLE A2FundLimits.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2SectionL1LimitsTemp.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2SectionL1Limits.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2SectionL2Limits.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2AgencyLimits.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2OrganizationLimits.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2ActivityLimits.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2FunctionLimits.sql', 'r').read())
    db.commit()

def summarize_dimensions(cur):
    # Construct summaries of each dimension
    cur.execute(open(r'SQLScripts\CREATE TABLE A2Funds.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2Agencies.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2Organizations.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2Activities.sql', 'r').read())
    cur.execute(open(r'SQLScripts\CREATE TABLE A2Functions.sql', 'r').read())
    db.commit()

def build_output_table(cur):
    
    # build and populate output table as A2TBLOut    
    cur.execute(open(r'SQLScripts\CREATE TABLE A2TBLOut.sql', 'r').read())
    db.commit()

def validate_totals(cur, validation, outname):
    
    cur.execute(open('SQLScripts\\' + validation + '.sql', 'r').read())
    f = open('Output\\' + outname + ' ' + validation + '.txt', 'w')
    names = list(map(lambda x: x[0], cur.description))
    print >>f,'\t'.join(names)
    for row in cur:
        print >>f,'\t'.join(str(e)) for e in row



########################
# Program starts here: #
########################


# Pre-compile all regular expressions patterns to be used
pNumber = re.compile(r'^(\()?\$?(\d{0,3})(?:,(\d{3}))?(?:,(\d{3}))?(?:,(\d{3}))?(?:,(\d{3}))?\.(\d{2})(\))?\n$')
pAccount = re.compile(r'^([0-9A-Za-z]{4}(?:\.[0-9A-Za-z]{4})?)\n$')
pRunBy = re.compile(r'^Run by (.+) on (\d{2}/\d{2}/\d{4}) (\d{2}:\d{2}:\d{2} (?:AM|PM))\n$')
pSectionL1Code = re.compile(r'^(ASSETS|EXPENSES|LIABILITIES AND FUND EQUITY|REVENUES)\n$')
pSectionL1Totals = re.compile(r'^(ASSETS|EXPENSES|LIABILITIES AND FUND EQUITY|REVENUES) TOTALS\n$')
pSectionL2Code = re.compile(r'^(FUND EQUITY|LIABILITIES)\n$')
pSectionL2Totals = re.compile(r'^(FUND EQUITY|LIABILITIES) TOTALS\n$')
pGroupHeader = re.compile(r'^(Fund|Agency|Organization|Activity|Function) \(cid:160\)  ([0-9A-Za-z]{3,4}) - (.+)\n$')
pGroupTotals = re.compile(r'^(Fund|Agency|Organization|Activity|Function) \(cid:160\)  ([0-9A-Za-z]{3,4}) - (.+) Totals\n$')
pGroupPartial = re.compile(r'^(Agency|Organization|Activity|Function) \(cid:160\)  ([0-9A-Za-z]{3,4}) - (.+)\n$')
pGrandTotals = re.compile(r'^Grand Totals\n$')
pMiscTotals = re.compile(r'^(.*?) *Totals\n$')
pColumnHeader = re.compile(r'^(?:Account|Account Description|Prior Year|YTD Balance|YTD Debits|YTD Credits|Balance Forward|Ending Balance)\n$')
pPageHeader = re.compile(r'^(?:Trial Balance Listing|Exclude Rollup Account|Detail Listing)\n$')
pThroughDate = re.compile(r'^Through (\d{2}/\d{2}/\d{2})\n$')
pPageNumber = re.compile(r'^Page \d{1,3} of \d{3}\n$')
pCid = re.compile(r'^.* \(cid:160\)  .*\n$')

# Connect to a new sqlite database
db = sqlite3.connect("Output\\" + str(sys.argv[1]) + ".sqlite")
cur = db.cursor()
init_db(cur)

# Open the input PDF report
fp = open("Reports\\" + str(sys.argv[1]) + ".pdf", 'rb')

# Create a PDF parser object associated with the file object.
parser = PDFParser(fp)

# Create a PDF document object that stores the document structure.
# Password for initialization as 2nd parameter
document = PDFDocument(parser)

# Check if the document allows text extraction. If not, abort.
if not document.is_extractable:
    raise PDFTextExtractionNotAllowed

# Create a PDF resource manager object that stores shared resources.
rsrcmgr = PDFResourceManager()

# Create a PDF device object.
device = PDFDevice(rsrcmgr)

# BEGIN LAYOUT ANALYSIS
# Set parameters for analysis.
laparams = LAParams()

# Create a PDF page aggregator object.
device = PDFPageAggregator(rsrcmgr, laparams=laparams)

# Create a PDF interpreter object.
interpreter = PDFPageInterpreter(rsrcmgr, device)

# initialize the page number
myPageNum = 1

# loop over all pages in the document
for page in PDFPage.create_pages(document):
    
    # read the page into a layout object
    interpreter.process_page(page)
    layout = device.get_result()
    
    # extract text from this object
    parse_obj(cur, layout._objs)
    
    # commit the new page's information to the database
    db.commit()
    
    # advance the page number
    myPageNum = myPageNum + 1

merge_records(cur)
update_total_records(cur)
group_sect_limits(cur)
summarize_dimensions(cur)

build_output_table(cur)

#validate_totals(cur, str(sys.argv[1]), "Validation By Fund")

db.commit()
db.close()
