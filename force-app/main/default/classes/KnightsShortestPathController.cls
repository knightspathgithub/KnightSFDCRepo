public class KnightsShortestPathController {

    public String outputPositions { get; set; }

    public String inputPositions { get; set; }
    
    static Map<String, Integer> xAxisLetterToNumberMap = new Map<String, Integer>();
    static Map<Integer, Integer> yAxisIndexToReverseIndexMap = new Map<Integer, Integer>();
    static Map<Integer, String> xAxisIndexToLettersMap = new Map<Integer, String>();
        
    static {
        xAxisLetterToNumberMap.put('A', 1);
        xAxisLetterToNumberMap.put('B', 2);
        xAxisLetterToNumberMap.put('C', 3);
        xAxisLetterToNumberMap.put('D', 4);
        xAxisLetterToNumberMap.put('E', 5);
        xAxisLetterToNumberMap.put('F', 6);
        xAxisLetterToNumberMap.put('G', 7);
        xAxisLetterToNumberMap.put('H', 8);
        
        yAxisIndexToReverseIndexMap.put(8, 1);
        yAxisIndexToReverseIndexMap.put(7, 2);
        yAxisIndexToReverseIndexMap.put(6, 3);
        yAxisIndexToReverseIndexMap.put(5, 4);
        yAxisIndexToReverseIndexMap.put(4, 5);
        yAxisIndexToReverseIndexMap.put(3, 6);
        yAxisIndexToReverseIndexMap.put(2, 7);
        yAxisIndexToReverseIndexMap.put(1, 8);
        
        xAxisIndexToLettersMap.put(1, 'A');
        xAxisIndexToLettersMap.put(2, 'B');
        xAxisIndexToLettersMap.put(3, 'C');
        xAxisIndexToLettersMap.put(4, 'D');
        xAxisIndexToLettersMap.put(5, 'E');
        xAxisIndexToLettersMap.put(6, 'F');
        xAxisIndexToLettersMap.put(7, 'G');
        xAxisIndexToLettersMap.put(8, 'H');
    }
    
    
    public PageReference getShortestPath() {
        Integer sizeOfBoard = 8;
        outputPositions = '';
        
        List<String> listOfInpuPositions = inputPositions.split('\n|\r\n');
        for(String inpuPosition : listOfInpuPositions) {
            try {
                // Get sourceX, sourceY, destX, destY from inputline
                Integer sourceY;
                Integer destY;
                String sourceX;
                String destX;

                sourceX = inpuPosition.substring(0,1);
                sourceY = Integer.valueOf(inpuPosition.substring(1,2));
                
                destX = inpuPosition.substring(3,4);
                destY = Integer.valueOf(inpuPosition.right(1));
                
                //Converting into corresponding 1 to 8 x-axis index for the given input line X-axis values from A to H.
                Integer[] startingPointXYIndexes = new Integer[] { xAxisLetterToNumberMap.get(sourceX), yAxisIndexToReverseIndexMap.get(sourceY) };
                //Converting into corresponding 1 to 8 y-axis index for the given input line Y-axis values
                Integer[] targetPointXYIndexes = new Integer[] { xAxisLetterToNumberMap.get(destX), yAxisIndexToReverseIndexMap.get(destY) };
                
                //Check if input is out of board
                if(!isInsideBoard(startingPointXYIndexes[0], startingPointXYIndexes[1], sizeOfBoard)
                    || !isInsideBoard(targetPointXYIndexes[0], targetPointXYIndexes[1], sizeOfBoard)) {
                        String errorMessage  = 'Please enter starting point and target points inside the ' + sizeOfBoard +'x'+ sizeOfBoard+ ' Chess Board as shown below <br/>'
                                        +'D4 G7 <br/>'
                                        +'D4 D5 <br/>';
                
                        ApexPages.Message errorMsg= new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
                        ApexPages.addMessage(errorMsg);
                        outputPositions ='';
                        return null;
                }

                if(String.isNotBlank(outputPositions )) {
                    outputPositions = outputPositions +'\n'+ shortestPathToTarget(startingPointXYIndexes, targetPointXYIndexes, sizeOfBoard);
                } else {
                    outputPositions = shortestPathToTarget(startingPointXYIndexes, targetPointXYIndexes, sizeOfBoard);
                }
                
                
            } catch(Exception e) {
                String errorMessage  = 'Please enter valid input lines in the below format <br/>'
                                        +'D4 G7 <br/>'
                                        +'D4 D5 <br/>';
                
                ApexPages.Message errorMsg= new ApexPages.Message(ApexPages.Severity.ERROR,errorMessage);
                ApexPages.addMessage(errorMsg);
                outputPositions ='';
                return null;
            }
            
        }

        return null;
    }
    
    
    /** 
     * This method checks whether the given xIndex and yIndex are inside the board or outside the board.
     * 
     * @param  xIndex  an absolute URL giving the base location of the image
     * @param  yIndex the location of the image, relative to the url argument
     * @param  sizeOfBoard is the size of the Chess Board.
     * @return Returns true if the xIndex and yIndex are inside the chess board else Returns false
     */

    static boolean isInsideBoard(Integer xIndex, Integer yIndex, Integer sizeOfBoard) {
        if (xIndex >= 1 && xIndex <= sizeOfBoard && yIndex >= 1 && yIndex <= sizeOfBoard) {
            return true;
        }
        return false;
    }
    

    /** 
     * This method finds the shortest path for the given starting point position and target point position.
     * 
     * @param  startingPointXYIndexes  starting point position, for example {D,4}
     * @param  targetPointXYIndexes target point position, for example {G,7}
     * @param  sizeOfBoard is the size of the Chess Board.
     * @return Returns true if the xIndex and yIndex are inside the chess board else Returns false
     */
    static String shortestPathToTarget(Integer[] startingPointXYIndexes, Integer[] targetPointXYIndexes, Integer sizeOfBoard) {
        //Possible x-axis and y-axis values from any given place for the night. I.e L-shape movements: 2 squares along one dimension, 1 square along the other.
        Integer[] possibleXmovableIndexes = new Integer[] { 2, 1, -2, -1, 2, 1, -2, -1 };
        Integer[] possibleYmovableIndexes = new Integer[] { 1, 2, 1, 2, -1, -2, -1, -2 };
        
        List<Square> movedPlaces = new List<Square>();

        movedPlaces.add(new Square(startingPointXYIndexes[0], startingPointXYIndexes[1], xAxisIndexToLettersMap.get(startingPointXYIndexes[0]) + yAxisIndexToReverseIndexMap.get(startingPointXYIndexes[1]) + ' '));

        Square movedToSquare;
        Integer nextXindex;
        Integer nextYindex;
        
        
        //Maintaining the 2 dimensional array for the chessboard and assigning initial visited values as false for all the chess board squares.
        List<List<Boolean>> visit = new List<List<Boolean>>();
        for(Integer xIndex = 1; xIndex <= sizeOfBoard; xIndex++)
        {   
            List<Boolean> columnVisits = new List<Boolean>();
            for(Integer yIndex = 1; yIndex <= sizeOfBoard; yIndex++)
            {
                columnVisits.add(false);        
            }
            visit.add(columnVisits);
        }

            
        //Making the starting square as visited.
        visit[startingPointXYIndexes[0]-1][startingPointXYIndexes[1]-1] = true;
        
        while (!movedPlaces.isEmpty()) {
            movedToSquare = movedPlaces[0];
            movedPlaces.remove(0);

            //Returning the path when the target is reached.
            if (movedToSquare.xIndex == targetPointXYIndexes[0] && movedToSquare.yIndex == targetPointXYIndexes[1]) {
                return (movedToSquare.path).trim();
            }

            //If the target is not reached, moving to the next possible Knight's square (i.e in L- Shape)
            for (Integer squareIndex = 0; squareIndex < 8; squareIndex++) {
                
                nextXindex = movedToSquare.xIndex + possibleXmovableIndexes[squareIndex];
                nextYindex = movedToSquare.yIndex + possibleYmovableIndexes[squareIndex];
                //move to the next possible square only if it is inside the board and the square is not already visited.
                if (isInsideBoard(nextXindex, nextYindex, sizeOfBoard) && !visit[nextXindex-1][nextYindex-1]) {
                    visit[nextXindex-1][nextYindex-1] = true;
                    //Moving to the next possible square
                    movedPlaces.add(new Square(nextXindex, nextYindex, movedToSquare.path + xAxisIndexToLettersMap.get(nextXindex) + yAxisIndexToReverseIndexMap.get(nextYindex) + ' '));
                }
            }
        }
        return '';
    }
    
    /**
    * The Square to represent each box of the chess board with it's x-axis, y-axis values.
    *  
    */
    class Square {
        Integer xIndex;
        Integer yIndex;
        String path = '';

        public Square(Integer pXindex, Integer pYindex, String pPath) {
            this.xIndex = pXindex;
            this.yIndex = pYindex;
            this.path = pPath;
        }
    }
}