public class RandomUtil  {

    // the random number seed will be an 8 digit integer
    public static Integer generateSeed() {
        return Math.round(Math.random()*10000000);
    }

    // this restricts the upper limit of the random number
    public static Integer getBoundedRandomNumber(Integer upperLimit) {
        return Math.mod(generateSeed(), upperLimit);
    }

    // magic shuffle
    public static List<Integer> shuffleMatch(Integer listSize) {

        List<Integer> matched = new List<Integer>();

        Integer numberOfIterations = 0;

        for(Integer i = 0; i < listSize; i++) {
            Integer chosen;
            while(chosen == null || chosen == i || matched.contains(chosen)) {
                chosen = RandomUtil.getBoundedRandomNumber(listSize);
                numberOfIterations++;
            }
            matched.add(chosen + 0);
        }

        return matched;
    }
}